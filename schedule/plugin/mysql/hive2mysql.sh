#!/bin/bash

#hive到mysql数据同步
#用法：./hive2mysql $table_name

function init_config()
{
    #hive数据源
    hive_db_name=default

    #mysql数据目标
    mysql_db_host=172.17.210.180
    mysql_db_user=dc_scheduler_cli
    mysql_db_passwd=dc_scheduler_cli
    mysql_db_name=test

    #sql日志目录
    sql_log_path=/$USER/tmp
    #临时文件目录
    tmp_path=/$USER/tmp
    #数据文件目录
    data_path=/$USER/data

    mkdir -p $sql_log_path 2> /dev/null
    mkdir -p $tmp_path 2> /dev/null
    mkdir -p $data_path 2> /dev/null

    #测试数据量
    test_limit="limit 10000"
}

#记录日志
function log()
{
  echo `date +'%Y-%m-%d %H:%M:%S'`" $@"
}

#在方法执行前后记录日志
function log_fn()
{
  echo `date +'%Y-%m-%d %H:%M:%S'`" $@ begin"
  $@
  echo `date +'%Y-%m-%d %H:%M:%S'`" $@ end"
}

#执行hive sql
function hive_executor()
{
    local sql="$1"
    if [ -z "$sql" ]; then
        sql=`cat`
    fi

    log "$sql" >> $sql_log_path/sql.log

    hive -S --database $hive_db_name -e "$sql"
}

#执行mysql sql
function mysql_executor()
{
    local sql="$1"
    if [ -z "$sql" ]; then
        sql=`cat`
    fi

    log "$sql" >> $sql_log_path/sql.log

    mysql -h$mysql_db_host -u$mysql_db_user -p$mysql_db_passwd $mysql_db_name -s -N --local-infile -e "$sql"
}

#字符类型转换
function conv_string()
{
    sed 's/\tstring\t/\ttext\t/ig'
}

#日期类型转换
function conv_date()
{
    sed 's/\ttimestamp\t/\tdatetime\t/ig'
}

#数据类型转换
function conv_data_type()
{
    conv_string | conv_date
}

#格式化字段
function format_columns()
{
    sed 's/^\([^ ]*\)[[:space:]]*\([^ ]*\)[[:space:]]*\(.*\)/\1\t\2\t\3/g;s/[[:space:]]*$//g'
}

#获取表字段
function get_columns()
{
    hive_executor "desc $table_name;" | format_columns > $tmp_path/$table_name.def
}

#mysql转义
function mysql_escape()
{
    sed "s/\('\|\"\)/\\\\\1/g"
}

#生成建表语句
function build_create_sql()
{
    echo "CREATE TABLE IF NOT EXISTS $table_name("
    cat $tmp_path/$table_name.def | conv_data_type | mysql_escape | awk -F '\t' '{
        printf("    %s %s COMMENT '\''%s'\'',\n",$1,$2,$3)
    }' | sed '$s/,$//'
    echo ");"
}

#创建表
function create_table()
{
    build_create_sql | tee $data_path/$table_name.ctl | mysql_executor
}

#获取字段分隔符
function get_field_separator()
{
    hive_executor "show create table $table_name;" | grep -i "FIELDS TERMINATED BY" | sed "s/.*'\(.*\)'.*/\1/"
}

#导出数据
function export_data()
{
    hive_executor "select * from $table_name $test_limit;" > $data_path/$table_name.txt
}

#导入数据
function load_data()
{
    mysql_executor "load data local infile '$data_path/$table_name.txt' ignore into table $table_name fields terminated by '`get_field_separator`';"
}

function main()
{
    table_name="$1"
    
    init_config

    log_fn get_columns

    log_fn create_table

    log_fn export_data

    log_fn load_data
}
main "$@"
