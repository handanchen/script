function execute_sql()
{
    local sql="$1"
    if [[ -z "$sql" ]]; then
        sql=`cat`
    fi

    echo "SET NAMES utf8;$sql" | mysql -h192.168.1.102 -uetl -p123456 zhenai_crm -s -N --local-infile
}

# �ֱ�
function sub_table()
{
  # �����ֱ�
    range_num 0 9 | while read num; do
        echo "drop table if exists user_register_$num;
        create table user_register_$num(
        user_id int comment '�û�ID',
        password varchar(64) comment '�û�����',
        realname varchar(32) comment '�û�����',
        gender tinyint comment '�Ա�',
        birthday date comment '����',
        email varchar(64) comment '����',
        address varchar(255) comment '��ַ',
        channel_id int comment '����ID',
        create_time datetime comment '����ʱ��',
        update_time datetime comment '����ʱ��',
        primary key(user_id)
        ) engine=MyISAM comment='�û�ע���';"
    done | execute_sql

    # �����ܱ�
    tables=`range_num 0 8 | awk '{
        printf("user_register_%s,",$1)
    }END{
        print "user_register_9"
    }'`

    echo "drop table if exists user_register;
    create table user_register(
        user_id int comment '�û�ID',
        password varchar(64) comment '�û�����',
        realname varchar(32) comment '�û�����',
        gender tinyint comment '�Ա�',
        birthday date comment '����',
        email varchar(64) comment '����',
        address varchar(255) comment '��ַ',
        channel_id int comment '����ID',
        create_time datetime comment '����ʱ��',
        update_time datetime comment '����ʱ��',
        primary key(user_id)
    ) ENGINE=MRG_MyISAM DEFAULT CHARSET=utf8 comment='�û�ע���' UNION=(${tables});
    " | execute_sql

    # ��������
    range_num 1 10000 | awk '{
        user_id=int($1)
        sub_num=substr($1,length($1))
        realname="�û�"$1
        gender=$1%2
        birthday="19880506 - interval "sub_num" day"
        email=$1"@163.com"
        address="�㶫ʡ�����б���������ֵ�"$1"��"
        printf("insert ignore into user_register_%s values(%s,\"%s\",\"%s\",%s,%s,\"%s\",\"%s\",%s,now(),now());\n",sub_num,user_id,$1,realname,gender,birthday,email,address,user_id)
    }' | execute_sql
}

# �±�
function month_table()
{
    # �����ֱ�
    range_date 201401 201407 | while read the_month; do
        echo "drop table if exists user_login_$the_month;
            create table user_login_$the_month(
            user_id int comment '�û�ID',
            login_time datetime comment '��¼ʱ��',
            channel_id int comment '����',
            primary key(user_id,login_time)
        ) engine=MyISAM comment='�û���¼��';"
    done | execute_sql

    # ��������
    range_date 2014010100 2014071018 | while read the_time; do
        echo "SELECT user_id,channel_id FROM user_register ORDER BY RAND() LIMIT 100;" |
        mysql -h192.168.1.100 -uetl -p123456 zhenai_crm |
        while read user_id channel_id; do
            echo "insert into user_login_${the_time:0:6} values 
            ($user_id,STR_TO_DATE(CONCAT('$the_time',date_format(now(),'%i%s')),'%Y%m%d%H%i%s'),$channel_id);"
        done | execute_sql
    done
}
