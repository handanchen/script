#!/bin/bash

#������Ϣ
function init_config()
{
    #oracle����Դ
    oracle_db_user=u_sd_bl
    oracle_db_password=belle
    oracle_db_name=ZBSHOESPLSQL_TEST_81
    oracle_db_url=$oracle_db_user/$oracle_db_password@$oracle_db_name

    #sql��־Ŀ¼
    sql_log_path=/$USER/tmp
    #��ʱ�ļ�Ŀ¼
    tmp_path=/$USER/tmp
    #�����ļ�Ŀ¼
    data_path=/$USER/data

    #Ŀ�������
    tar_server_host=172.17.210.120
    tar_server_user=root
    tar_server_passwd="172.17.210.120_Nnc0i4&1)P72"
    tar_data_path=/root/data

    mkdir -p $sql_log_path 2> /dev/null
    mkdir -p $tmp_path 2> /dev/null
    mkdir -p $data_path 2> /dev/null

    #����������
    test_limit="where rownum<10000"
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

#oracle sqlִ����
function oracle_executor()
{
    local sql="$1"

    if [ -z "$sql" ]; then
        sql=`cat`
    fi

    log "$sql" >> $sql_log_path/sql.log

sqlplus -S -L /nolog << EOF
connect $oracle_db_url
set echo off;
set feedback off;
set heading off;
set wrap off;
set pagesize 0;
set linesize 10000;
set numwidth 16;
set termout off;
set timing off;
set trimout on;
set trimspool on;
set colsep'|||';
$sql
commit;
quit
EOF
}

#��ʽ�����
#1��ȥ�����߿ո�
#2���ѿ��ַ����滻��NULL
#3������ָ�����Ϊtab
function format_data()
{
  awk -F '\\|\\|\\|' '{
    for(i=1;i<NF;i++){
      gsub(/^[[:space:]]*/,"",$i);
      gsub(/[[:space:]]*$/,"",$i);
      gsub(/^$/,"NULL",$i);
      printf("%s\t",$i)
    }
    gsub(/^[[:space:]]*/,"",$NF);
    gsub(/[[:space:]]*$/,"",$NF);
    gsub(/^$/,"NULL",$NF);
    printf("%s\n",$NF)
  }'
}

#��ȡ�ֶ���Ϣ
function get_columns()
{
    local sql="SELECT a.column_name,
       a.data_type,
       a.data_length,
       a.data_precision,
       a.data_scale,
       b.comments
  FROM all_tab_columns a
  LEFT JOIN all_col_comments b
    ON a.owner = b.owner
   AND a.table_name = b.table_name
   AND a.column_name = b.column_name
 WHERE a.owner = upper('$oracle_db_user')
   AND a.table_name = upper('$table_name');"

   oracle_executor "$sql" | format_data > $tmp_path/$table_name.ctl
}

#��ȡ��ע��
function get_table_comment()
{
    local sql="select comments from all_tab_comments where owner=upper('$oracle_db_user') and table_name=upper('$table_name');"

    oracle_executor "$sql"
}

#hiveת�������ַ�
function hive_escape()
{
    sed "s/\('\|;\)/\\\\\1/g"
}

#���ɽ������
function build_create_sql()
{   
    echo "CREATE TABLE IF NOT EXISTS $table_name("
    cat $tmp_path/$table_name.ctl | hive_escape | awk -F'\t' 'BEGIN{IGNORECASE=1}{
        if($2 == "NUMBER"){
            if($4 == "NULL"){
                printf("%    s INT COMMENT '\''%s'\'',\n",$1,$6)
            }else{
                printf("    %s DECIMAL(%s,%s) COMMENT '\''%s'\'',\n",$1,$4,$5,$6)
            }
        }else if($2 ~/char/){
            printf("    %s STRING COMMENT '\''%s'\'',\n",$1,$6)
        }else if($2 == "DATE"){
            printf("    %s TIMESTAMP COMMENT '\''%s'\'',\n",$1,$6)
        }
    }' | sed '$s/,$//'
    echo ") COMMENT '`get_table_comment`' ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE;"
}

#������
function create_table()
{
    build_create_sql > $data_path/$table_name.ctl
}

#���ɲ�ѯ�ֶ�
function build_select_cols()
{
    cat $tmp_path/$table_name.ctl | awk -F"\t" 'BEGIN{IGNORECASE=1}{
        if($2 == "DATE"){
            printf("to_char(%s,'\''yyyy-mm-dd hh24:mi:ss'\''),",$1)
        }else{
            printf("%s,",$1)
        }
    }' | sed 's/,$//'
}

#��������
function export_data()
{
    local sql="select `build_select_cols` from $table_name $test_limit;"

    oracle_executor "$sql" | format_data > $data_path/$table_name.txt
}

#���䵽����������
function transfer()
{
    #ѹ��
    zip -jm $data_path/$table_name.zip $data_path/$table_name.ctl $data_path/$table_name.txt

    #����
    ./expect_scp $tar_server_host $tar_server_user "$tar_server_passwd" $data_path/$table_name.zip $tar_data_path
}

#���hive test���ϵ����б�
function clear_hive()
{
    hive -S --database test -e "show tables;" | while read table_name; do
        echo "drop table if exists $table_name;"
    done | hive -S --database test
}

#װ�ص�hive
function load_hive()
{
    ls $tar_data_path/*.zip | while read file_name;do
        unzip -u $file_name
        hive -S --database test -f ${file_name%.*}.ctl
        hive -S --database test -e "load data local inpath '${file_name%.*}.txt' into table `basename ${file_name%.*}`;"
    done
}

function main()
{
    table_name="$1"

    init_config

    log_fn get_columns

    log_fn create_table

    log_fn export_data

    #log_fn transfer
}
main "$@"
