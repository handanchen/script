
#获取源表定义
#变量：src_table、src_columns、src_db_charset、src_db_url
function get_table_def()
{
  #包含列表
  #首尾各一个空格，其他空格都去掉
  #字段用“`”包起来，以免引起歧义
  includes=`echo "$src_columns" |
  sed 's/^[[:blank:]]*/ /g;s/[[:blank:]]*$/ /g;s/[[:blank:]]*,[[:blank:]]*/,/g' |
  sed "s/ /\\\`/g;s/,/\\\`|\\\`/g"`"|CREATE TABLE|ENGINE="

  #排除列表
  excludes="FOREIGN KEY"

  sed 's/Create Table: //i' | grep -iE "$includes" | grep -ivE "$excludes" 
}

#将源表定义转换成目标表定义
#变量：src_table、tar_table、tar_db_charset
function conv_table_def()
{
  sed "s/CREATE TABLE \`${src_table}\`/CREATE TABLE IF NOT EXISTS \`${tar_table}\`/i" |
  sed 's/\(AUTO_INCREMENT[=0-9]*\|on update CURRENT_TIMESTAMP\|UNIQUE \|COLLATE[ =][^ ]*\)//ig' |
  sed '/^[ ]* KEY .*/d' |
  sed 's/\(MRG_MyISAM\|InnoDB\|BRIGHTHOUSE\)/MyISAM/i' |
  sed "s/CHARSET=[^ ]*/CHARSET=${tar_db_charset}/i" |
  tac | sed '2s/,$//' | tac
}

#创建表
#1、获取源表定义
#2、转换成目标表定义
function create_table()
{
  execute_sql "set names $src_db_charset;show create table $src_table\G;" "$src_db_url" |
  get_table_def | tee ${task_tmp_path}/${src_table}.src_table.def |
  conv_table_def | tee ${task_tmp_path}/${tar_table}.tar_table.def |
  execute_sql "" "$tar_db_url"
}

#构建装载sql
function build_load_sql()
{
  echo "load data local infile '${task_data_path}/${src_table}.tmp' $load_mode into table $tar_table;"
}