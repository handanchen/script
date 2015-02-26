#!/bin/bash

# hive到postgresql表结构复制


# 临时文件目录
TMP_PATH=~/tmp

# hive数据源
src_dbs=(dc_retail_fms dc_retail_gms dc_retail_mdm dc_retail_mps dc_retail_pms dc_retail_pos)


# 执行hive sql
function hive_executor()
{
    local sql="$1"
    if [[ -z "$sql" ]]; then
        sql=`cat`
    fi

    hive -S --database $src_db_name -e "$sql"
}

# 整型类型转换
function conv_int()
{
    sed 's/\ttinyint\t/\tsmallint\t/ig'
}

# 字符类型转换
function conv_string()
{
    sed 's/\tstring\t/\ttext\t/ig'
}

# 日期类型转换
function conv_date()
{
    sed 's/\ttimestamp\t/\ttimestamp\t/ig'
}

# 数据类型转换
function conv_data_type()
{
    conv_int | conv_string | conv_date
}

# 记录日志
function log()
{
    echo "$(date +'%F %T') [$@]"
}

# 格式化字段
function format_columns()
{
    sed 's/^\([^ ]*\)[[:space:]]*\([^ ]*\)[[:space:]]*\(.*\)/\1\t\2\t\3/g;s/[[:space:]]*$//g'
}

# pg关键字加后缀
function pg_keyword_conv()
{
    sed 's/^\(A\|ABORT\|ABS\|ABSOLUTE\|ACCESS\|ACTION\|ADA\|ADD\|ADMIN\|AFTER\|AGGREGATE\|ALIAS\|ALL\|ALLOCATE\|ALSO\|ALTER\|ALWAYS\|ANALYSE\|ANALYZE\|AND\|ANY\|ARE\|ARRAY\|AS\|ASC\|ASENSITIVE\|ASSERTION\|ASSIGNMENT\|ASYMMETRIC\|AT\|ATOMIC\|ATTRIBUTE\|ATTRIBUTES\|AUTHORIZATION\|AVG\)\t/\1_\t/ig' |
    sed 's/^\(BACKWARD\|BEFORE\|BEGIN\|BERNOULLI\|BETWEEN\|BIGINT\|BINARY\|BIT\|BITVAR\|BIT_LENGTH\|BLOB\|BOOLEAN\|BOTH\|BREADTH\|BY\)\t/\1_\t/ig' |
    sed 's/^\(C\|CACHE\|CALL\|CALLED\|CARDINALITY\|CASCADE\|CASCADED\|CASE\|CAST\|CATALOG\|CATALOG_NAME\|CEIL\|CEILING\|CHAIN\|CHAR\|CHARACTER\|CHARACTERISTICS\|CHARACTERS\|CHARACTER_LENGTH\|CHARACTER_SET_CATALOG\|CHARACTER_SET_NAME\|CHARACTER_SET_SCHEMA\|CHAR_LENGTH\|CHECK\|CHECKED\|CHECKPOINT\|CLASS\|CLASS_ORIGIN\|CLOB\|CLOSE\|CLUSTER\|COALESCE\|COBOL\|COLLATE\|COLLATION\|COLLATION_CATALOG\|COLLATION_NAME\|COLLATION_SCHEMA\|COLLECT\|COLUMN\|COLUMN_NAME\|COMMAND_FUNCTION\|COMMAND_FUNCTION_CODE\|COMMENT\|COMMIT\|COMMITTED\|COMPLETION\|CONDITION\|CONDITION_NUMBER\|CONNECT\|CONNECTION\|CONNECTION_NAME\|CONSTRAINT\|CONSTRAINTS\|CONSTRAINT_CATALOG\|CONSTRAINT_NAME\|CONSTRAINT_SCHEMA\|CONSTRUCTOR\|CONTAINS\|CONTINUE\|CONVERSION\|CONVERT\|COPY\|CORR\|CORRESPONDING\|COUNT\|COVAR_POP\|COVAR_SAMP\|CREATE\|CREATEDB\|CREATEROLE\|CREATEUSER\|CROSS\|CSV\|CUBE\|CUME_DIST\|CURRENT\|CURRENT_DATE\|CURRENT_DEFAULT_TRANSFORM_GROUP\|CURRENT_PATH\|CURRENT_ROLE\|CURRENT_TIME\|CURRENT_TIMESTAMP\|CURRENT_TRANSFORM_GROUP_FOR_TYPE\|CURRENT_USER\|CURSOR\|CURSOR_NAME\|CYCLE\)\t/\1_\t/ig' |
    sed 's/^\(DATA\|DATABASE\|DATE\|DATETIME_INTERVAL_CODE\|DATETIME_INTERVAL_PRECISION\|DAY\|DEALLOCATE\|DEC\|DECIMAL\|DECLARE\|DEFAULT\|DEFAULTS\|DEFERRABLE\|DEFERRED\|DEFINED\|DEFINER\|DEGREE\|DELETE\|DELIMITER\|DELIMITERS\|DENSE_RANK\|DEPTH\|DEREF\|DERIVED\|DESC\|DESCRIBE\|DESCRIPTOR\|DESTROY\|DESTRUCTOR\|DETERMINISTIC\|DIAGNOSTICS\|DICTIONARY\|DISABLE\|DISCONNECT\|DISPATCH\|DISTINCT\|DO\|DOMAIN\|DOUBLE\|DROP\|DYNAMIC\|DYNAMIC_FUNCTION\|DYNAMIC_FUNCTION_CODE\)\t/\1_\t/ig' |
    sed 's/^\(EACH\|ELEMENT\|ELSE\|ENABLE\|ENCODING\|ENCRYPTED\|END\|END-EXEC\|EQUALS\|ESCAPE\|EVERY\|EXCEPT\|EXCEPTION\|EXCLUDE\|EXCLUDING\|EXCLUSIVE\|EXEC\|EXECUTE\|EXISTING\|EXISTS\|EXP\|EXPLAIN\|EXTERNAL\|EXTRACT\)\t/\1_\t/ig' |
    sed 's/^\(FALSE\|FETCH\|FILTER\|FINAL\|FIRST\|FLOAT\|FLOOR\|FOLLOWING\|FOR\|FORCE\|FOREIGN\|FORTRAN\|FORWARD\|FOUND\|FREE\|FREEZE\|FROM\|FULL\|FUNCTION\|FUSION\)\t/\1_\t/ig' |
    sed 's/^\(G\|GENERAL\|GENERATED\|GET\|GLOBAL\|GO\|GOTO\|GRANT\|GRANTED\|GREATEST\|GROUP\|GROUPING\)\t/\1_\t/ig' |
    sed 's/^\(HANDLER\|HAVING\|HEADER\|HIERARCHY\|HOLD\|HOST\|HOUR\)\t/\1_\t/ig' |
    sed 's/^\(IDENTITY\|IGNORE\|ILIKE\|IMMEDIATE\|IMMUTABLE\|IMPLEMENTATION\|IMPLICIT\|IN\|INCLUDING\|INCREMENT\|INDEX\|INDICATOR\|INFIX\|INHERIT\|INHERITS\|INITIALIZE\|INITIALLY\|INNER\|INOUT\|INPUT\|INSENSITIVE\|INSERT\|INSTANCE\|INSTANTIABLE\|INSTEAD\|INT\|INTEGER\|INTERSECT\|INTERSECTION\|INTERVAL\|INTO\|INVOKER\|IS\|ISNULL\|ISOLATION\|ITERATE\)\t/\1_\t/ig' |
    sed 's/^\(JOIN\)\t/\1_\t/ig' |
    sed 's/^\(K\|KEY\|KEY_MEMBER\|KEY_TYPE\)\t/\1_\t/ig' |
    sed 's/^\(LANCOMPILER\|LANGUAGE\|LARGE\|LAST\|LATERAL\|LEADING\|LEAST\|LEFT\|LENGTH\|LESS\|LEVEL\|LIKE\|LIMIT\|LISTEN\|LN\|LOAD\|LOCAL\|LOCALTIME\|LOCALTIMESTAMP\|LOCATION\|LOCATOR\|LOGIN\|LOCK\|LOWER\)\t/\1_\t/ig' |
    sed 's/^\(M\|MAP\|MATCH\|MATCHED\|MAX\|MAXVALUE\|MEMBER\|MERGE\|MESSAGE_LENGTH\|MESSAGE_OCTET_LENGTH\|MESSAGE_TEXT\|METHOD\|MIN\|MINUTE\|MINVALUE\|MOD\|MODE\|MODIFIES\|MODIFY\|MODULE\|MONTH\|MORE\|MOVE\|MULTISET\|MUMPS\)\t/\1_\t/ig' |
    sed 's/^\(NAME\|NAMES\|NATIONAL\|NATURAL\|NCHAR\|NCLOB\|NESTING\|NEW\|NEXT\|NO\|NOCREATEDB\|NOCREATEROLE\|NOCREATEUSER\|NOINHERIT\|NOLOGIN\|NONE\|NORMALIZE\|NORMALIZED\|NOSUPERUSER\|NOT\|NOTHING\|NOTIFY\|NOTNULL\|NOWAIT\|NULL\|NULLABLE\|NULLIF\|NULLS\|NUMBER\|NUMERIC\)\t/\1_\t/ig' |
    sed 's/^\(OBJECT\|OCTETS\|OCTET_LENGTH\|OF\|OFF\|OFFSET\|OIDS\|OLD\|ON\|ONLY\|OPEN\|OPERATION\|OPERATOR\|OPTION\|OPTIONS\|OR\|ORDER\|ORDERING\|ORDINALITY\|OTHERS\|OUT\|OUTER\|OUTPUT\|OVER\|OVERLAPS\|OVERLAY\|OVERRIDING\|OWNER\)\t/\1_\t/ig' |
    sed 's/^\(PAD\|PARAMETER\|PARAMETERS\|PARAMETER_MODE\|PARAMETER_NAME\|PARAMETER_ORDINAL_POSITION\|PARAMETER_SPECIFIC_CATALOG\|PARAMETER_SPECIFIC_NAME\|PARAMETER_SPECIFIC_SCHEMA\|PARTIAL\|PARTITION\|PASCAL\|PASSWORD\|PATH\|PERCENTILE_CONT\|PERCENTILE_DISC\|PERCENT_RANK\|PLACING\|PLI\|POSITION\|POSTFIX\|POWER\|PRECEDING\|PRECISION\|PREFIX\|PREORDER\|PREPARE\|PREPARED\|PRESERVE\|PRIMARY\|PRIOR\|PRIVILEGES\|PROCEDURAL\|PROCEDURE\|PUBLIC\)\t/\1_\t/ig' |
    sed 's/^\(QUOTE\)\t/\1_\t/ig' |
    sed 's/^\(RANGE\|RANK\|READ\|READS\|REAL\|RECHECK\|RECURSIVE\|REF\|REFERENCES\|REFERENCING\|REGR_AVGX\|REGR_AVGY\|REGR_COUNT\|REGR_INTERCEPT\|REGR_R2\|REGR_SLOPE\|REGR_SXX\|REGR_SXY\|REGR_SYY\|REINDEX\|RELATIVE\|RELEASE\|RENAME\|REPEATABLE\|REPLACE\|RESET\|RESTRICT\|RESULT\|RETURN\|RETURNED_CARDINALITY\|RETURNED_LENGTH\|RETURNED_OCTET_LENGTH\|RETURNED_SQLSTATE\|RETURNS\|REVOKE\|RIGHT\|ROLE\|ROLLBACK\|ROLLUP\|ROUTINE\|ROUTINE_CATALOG\|ROUTINE_NAME\|ROUTINE_SCHEMA\|ROW\|ROWS\|ROW_COUNT\|ROW_NUMBER\|RULE\)\t/\1_\t/ig' |
    sed 's/^\(SAVEPOINT\|SCALE\|SCHEMA\|SCHEMA_NAME\|SCOPE\|SCOPE_CATALOG\|SCOPE_NAME\|SCOPE_SCHEMA\|SCROLL\|SEARCH\|SECOND\|SECTION\|SECURITY\|SELECT\|SELF\|SENSITIVE\|SEQUENCE\|SERIALIZABLE\|SERVER_NAME\|SESSION\|SESSION_USER\|SET\|SETOF\|SETS\|SHARE\|SHOW\|SIMILAR\|SIMPLE\|SIZE\|SMALLINT\|SOME\|SOURCE\|SPACE\|SPECIFIC\|SPECIFICTYPE\|SPECIFIC_NAME\|SQL\|SQLCODE\|SQLERROR\|SQLEXCEPTION\|SQLSTATE\|SQLWARNING\|SQRT\|STABLE\|START\|STATE\|STATEMENT\|STATIC\|STATISTICS\|STDDEV_POP\|STDDEV_SAMP\|STDIN\|STDOUT\|STORAGE\|STRICT\|STRUCTURE\|STYLE\|SUBCLASS_ORIGIN\|SUBLIST\|SUBMULTISET\|SUBSTRING\|SUM\|SUPERUSER\|SYMMETRIC\|SYSID\|SYSTEM\|SYSTEM_USER\)\t/\1_\t/ig' |
    sed 's/^\(TABLE\|TABLESAMPLE\|TABLESPACE\|TABLE_NAME\|TEMP\|TEMPLATE\|TEMPORARY\|TERMINATE\|THAN\|THEN\|TIES\|TIME\|TIMESTAMP\|TIMEZONE_HOUR\|TIMEZONE_MINUTE\|TO\|TOAST\|TOP_LEVEL_COUNT\|TRAILING\|TRANSACTION\|TRANSACTIONS_COMMITTED\|TRANSACTIONS_ROLLED_BACK\|TRANSACTION_ACTIVE\|TRANSFORM\|TRANSFORMS\|TRANSLATE\|TRANSLATION\|TREAT\|TRIGGER\|TRIGGER_CATALOG\|TRIGGER_NAME\|TRIGGER_SCHEMA\|TRIM\|TRUE\|TRUNCATE\|TRUSTED\|TYPE\)\t/\1_\t/ig' |
    sed 's/^\(UESCAPE\|UNBOUNDED\|UNCOMMITTED\|UNDER\|UNENCRYPTED\|UNION\|UNIQUE\|UNKNOWN\|UNLISTEN\|UNNAMED\|UNNEST\|UNTIL\|UPDATE\|UPPER\|USAGE\|USER\|USER_DEFINED_TYPE_CATALOG\|USER_DEFINED_TYPE_CODE\|USER_DEFINED_TYPE_NAME\|USER_DEFINED_TYPE_SCHEMA\|USING\)\t/\1_\t/ig' |
    sed 's/^\(VACUUM\|VALID\|VALIDATOR\|VALUE\|VALUES\|VARCHAR\|VARIABLE\|VARYING\|VAR_POP\|VAR_SAMP\|VERBOSE\|VIEW\|VOLATILE\)\t/\1_\t/ig' |
    sed 's/^\(WHEN\|WHENEVER\|WHERE\|WIDTH_BUCKET\|WINDOW\|WITH\|WITHIN\|WITHOUT\|WORK\|WRITE\)\t/\1_\t/ig' |
    sed 's/^\(YEAR\)\t/\1_\t/ig'
}

# 获取表字段
function get_columns()
{
    hive_executor "desc $table_name;" | format_columns | pg_keyword_conv | grep -v hive_create_time
}

# 获取分区字段
function get_part_keys()
{
    sed '/^[[:space:]]*$/d' ${TMP_PATH}/$src_db_name/$table_name.def |
    awk -F '\t' '{
        if($0 ~ /^#[[:space:]]*Partition/) part=1
        if($0 ~ /^#[[:space:]]*col_name/) col=1
        if($0 !~ /^#/ && part == 1 && col == 1) print $0
    }' | tr '\n' '|' | sed 's/.$//'
}

# 生成建表语句
function build_create_sql()
{
    # 建表语句
    echo "CREATE TABLE IF NOT EXISTS $table_name ("
    sed '/^#/,/$!/d;/^[[:space:]]*$/d' ${TMP_PATH}/$src_db_name/$table_name.def |
    grep -Ev "${part_keys:-undefined}" |
    conv_data_type | awk -F '\t' '{
        printf("  %s %s,\n",$1,$2)
    }' | sed '$s/,$//'
    echo ");"
}

# 添加字段注释
function add_columns_comment()
{
    # 字段注释
    sed '/^#/,/$!/d;/^[[:space:]]*$/d' ${TMP_PATH}/$src_db_name/$table_name.def |
    grep -Ev "${part_keys:-undefined}" |
    awk -F '\t' '{
        printf("COMMENT ON COLUMN '$table_name'.%s IS '\'%s''\'';\n",$1,$3)
    }'
}

# 创建表
function create_table()
{
    # 创建目录
    mkdir -p $TMP_PATH/$src_db_name

    # 获取字段
    log "get columns begin"
    get_columns > ${TMP_PATH}/$src_db_name/$table_name.def
    log "get columns end"

    # 获取分区字段
    log "get partition keys begin"
    part_keys=`get_part_keys`
    log "get partition keys [$part_keys] end"

    # 生成postgresql建表语句
    log "build create sql begin"
    build_create_sql > ${TMP_PATH}/$src_db_name/$table_name.ctl
    log "build create sql end"

    # 添加字段注释
    log "add columns comment begin"
    add_columns_comment >> ${TMP_PATH}/$src_db_name/$table_name.ctl
    log "add columns comment end"
}

function main()
{
    # 遍历数据库
    for src_db_name in "${src_dbs[@]}"; do
        # 遍历表
        hive_executor "show tables;" | while read table_name; do
            # 创建表
            log "create table $src_db_name.$table_name begin"
            create_table
            log "create table $src_db_name.$table_name end"
        done
        # 合并数据库
        cat ${TMP_PATH}/$src_db_name/*.ctl > ${TMP_PATH}/$src_db_name.ctl
    done
}
main "$@"
