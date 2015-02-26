#!/bin/bash

#hive��mysql����ͬ��
#�÷���./hive2mysql $table_name

function init_config()
{
    #hive����Դ
    hive_db_name=default

    #mysql����Ŀ��
    mysql_db_host=172.17.210.180
    mysql_db_user=dc_scheduler_cli
    mysql_db_passwd=dc_scheduler_cli
    mysql_db_name=test

    #sql��־Ŀ¼
    sql_log_path=/$USER/tmp
    #��ʱ�ļ�Ŀ¼
    tmp_path=/$USER/tmp
    #�����ļ�Ŀ¼
    data_path=/$USER/data

    mkdir -p $sql_log_path 2> /dev/null
    mkdir -p $tmp_path 2> /dev/null
    mkdir -p $data_path 2> /dev/null

    #����������
    test_limit="limit 10000"
}

#��¼��־
function log()
{
  echo `date +'%Y-%m-%d %H:%M:%S'`" $@"
}

#�ڷ���ִ��ǰ���¼��־
function log_fn()
{
  echo `date +'%Y-%m-%d %H:%M:%S'`" $@ begin"
  $@
  echo `date +'%Y-%m-%d %H:%M:%S'`" $@ end"
}

#ִ��hive sql
function hive_executor()
{
    local sql="$1"
    if [ -z "$sql" ]; then
        sql=`cat`
    fi

    log "$sql" >> $sql_log_path/sql.log

    hive -S --database $hive_db_name -e "$sql"
}

#ִ��mysql sql
function mysql_executor()
{
    local sql="$1"
    if [ -z "$sql" ]; then
        sql=`cat`
    fi

    log "$sql" >> $sql_log_path/sql.log

    mysql -h$mysql_db_host -u$mysql_db_user -p$mysql_db_passwd $mysql_db_name -s -N --local-infile -e "$sql"
}

#�ַ�����ת��
function conv_string()
{
    sed 's/\tstring\t/\ttext\t/ig'
}

#��������ת��
function conv_date()
{
    sed 's/\ttimestamp\t/\tdatetime\t/ig'
}

#��������ת��
function conv_data_type()
{
    conv_string | conv_date
}

#��ʽ���ֶ�
function format_columns()
{
    sed 's/^\([^ ]*\)[[:space:]]*\([^ ]*\)[[:space:]]*\(.*\)/\1\t\2\t\3/g;s/[[:space:]]*$//g'
}

#��ȡ���ֶ�
function get_columns()
{
    hive_executor "desc $table_name;" | format_columns > $tmp_path/$table_name.def
}

#mysqlת��
function mysql_escape()
{
    sed "s/\('\|\"\)/\\\\\1/g"
}

#���ɽ������
function build_create_sql()
{
    echo "CREATE TABLE IF NOT EXISTS $table_name("
    cat $tmp_path/$table_name.def | conv_data_type | mysql_escape | awk -F '\t' '{
        printf("    %s %s COMMENT '\''%s'\'',\n",$1,$2,$3)
    }' | sed '$s/,$//'
    echo ");"
}

#������
function create_table()
{
    build_create_sql | tee $data_path/$table_name.ctl | mysql_executor
}

#��ȡ�ֶηָ���
function get_field_separator()
{
    hive_executor "show create table $table_name;" | grep -i "FIELDS TERMINATED BY" | sed "s/.*'\(.*\)'.*/\1/"
}

#��������
function export_data()
{
    hive_executor "select * from $table_name $test_limit;" > $data_path/$table_name.txt
}

#��������
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
