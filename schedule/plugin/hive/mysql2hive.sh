#!/bin/bash
#
#mysql到hive数据同步


DIR=`pwd`

source $DIR/config.sh
source $DIR/common.sh

#创建目录
mkdir -p $SQL_LOG_PATH 2> /dev/null

# 设置数据源
# Globals:
# Arguments:
# Returns:
function set_src_db()
{
    src_db_host="$1"
    src_db_port="$2"
    src_db_user="$3"
    src_db_pass="$4"
    src_db_name="$5"
    src_db_charset="$6"
    src_db_params="$7"
}

# 设置数据目标
# Globals:
# Arguments:
# Returns:
function set_tar_db()
{
    tar_db_name="$1"
}

#执行mysql sql
function mysql_executor()
{
    local sql="$1"
    if [ -z "$sql" ]; then
        sql=`cat`
    fi

    [[ "$SQL_LOG" = "on" ]] && log "$sql" >> $SQL_LOG_PATH/sql_$(date +%Y%m%d).log

    mysql -h $src_db_host -P $src_db_port -u $src_db_user -p$src_db_pass -D $src_db_name --default-character-set=$src_db_charset $src_db_params -e "$sql"
}

#执行hive sql
function hive_executor()
{
    local sql="$1"
    if [ -z "$sql" ]; then
        sql=`cat`
    fi

    [[ "$SQL_LOG" = "on" ]] && log "$sql" >> $SQL_LOG_PATH/sql_$(date +%Y%m%d).log

    hive -S --database $tar_db_name -e "$sql"
}

# 整型类型转换
# Globals:
# Arguments:
# Returns:
function conv_int()
{
    sed 's/ [^ ]*int(.*)/ int/ig;s/ year/ int/ig'
}

#字符类型转换
function conv_string()
{
    sed 's/ text\| enum(.*)\| set(.*)\| blob/ string/ig'
}

#日期类型转换
function conv_date()
{
    sed 's/ datetime.*/ timestamp/ig;s/ date&\| date(.*)$/ date/ig;s/ time$/ string/ig'
}

#数据类型转换
function conv_data_type()
{
    conv_int | conv_string | conv_date
}

# 获取表注释
function get_table_comment()
{
    grep "ENGINE=.* COMMENT=" $TMP_PATH/$src_db_name/$table_name.def | sed "s/.* COMMENT=\(.*\)/\1/i;s/'//g"
}

#生成建表语句
function build_create_sql()
{
    echo "CREATE TABLE IF NOT EXISTS $table_name("
    paste $TMP_PATH/$src_db_name/$table_name.cols $TMP_PATH/$src_db_name/$table_name.cmts | sed '$s/,$//'
    echo ") COMMENT '`get_table_comment`' PARTITIONED BY (biz_date int) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE;"
}

# 获取字段
# Globals:
# Arguments:
# Returns:
function get_columns()
{
    sed '1d;$d' $TMP_PATH/$src_db_name/$table_name.def |
    grep -Eiv " KEY " |
    sed 's/\([ ]*[^ ]*[ ]*[^ ]*\).*/\1/ig;s/`//g' |
    conv_data_type
}

# 获取字段注释
function get_columns_comment()
{
    sed '1d;$d' $TMP_PATH/$src_db_name/$table_name.def |
    grep -Eiv " KEY " |
    sed "s/.*COMMENT '\(.*\)',$/\1/ig;s/^[[:space:]]*\`.*//g" |
    sed 's/\\/\\\\/g' |
    hive_escape |
    sed "s/\(.*\)/COMMENT '\1',/g"
}

#创建表
function create_table()
{
    mysql_executor "SHOW CREATE TABLE $table_name\G;" | sed -n '3,$p' > $TMP_PATH/$src_db_name/$table_name.def

    get_columns > $TMP_PATH/$src_db_name/$table_name.cols
    get_columns_comment > $TMP_PATH/$src_db_name/$table_name.cmts

    build_create_sql | tee $DATA_PATH/$src_db_name/$table_name.ctl | hive_executor
}

# 格式化数据
# Globals:
# Arguments:
# Returns:
function format_data()
{
    sed 's/NULL/\\N/ig'
}

#导出数据
function export_data()
{
    mysql_executor "SELECT * FROM $table_name WHERE 1=1 $i_where" | format_data > $DATA_PATH/$src_db_name/${table_name}_${i}.txt
}

#导入数据
function load_data()
{
    hive_executor "LOAD DATA LOCAL INPATH '$DATA_PATH/$src_db_name/${table_name}_${i}.txt' INTO TABLE $table_name;"
}

# 传输
#   创建表
#   导出数据
#   导入数据
#   分页
# Globals:
#   table_name 表名
#   where 条件
#   action 操作指令

function transfer()
{
    #创建目录
    mkdir -p $TMP_PATH/$src_db_name 2> /dev/null
    mkdir -p $DATA_PATH/$src_db_name 2> /dev/null

    if [[ "$action" =~ "$CMD_CREATE_TABLE" ]]; then
        create_table || return $?
    fi

    local total_page=0
    if [[ "$action" =~ "$CMD_EXP_FILE" ]]; then
        total_count=$(mysql_executor "SELECT COUNT(*) FROM $table_name WHERE 1=1 $where")
        total_page=$((total_count % PAGE_SIZE == 0 ? total_count / PAGE_SIZE : total_count / PAGE_SIZE + 1))
    fi

    for((i=1;i<=$total_page;i++)); do
        offset=$(((i-1) * PAGE_SIZE))
        i_where="$where limit $offset,$PAGE_SIZE"

        if [[ "$action" =~ "$CMD_EXP_FILE" ]]; then
            export_data || return $?
        fi

        if [[ "$action" =~ "$CMD_IMP_DATA" ]]; then
            load_data || return $?
        fi
    done
}
