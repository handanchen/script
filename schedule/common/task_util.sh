# 任务工具


source $SCHED_HOME/common/config.sh


# 执行sql语句
function execute_meta()
{
    local sql="$1"
    if [[ -z "$sql" ]]; then
      sql=`cat`
    fi

    SQL_LOG=$META_SQL_LOG
    local sql_log_file=${META_SQL_LOG_PATH}/meta_sql_$(cur_date).log

    case $META_DB_TYPE in
        $DB_TYPE_MYSQL)
            mysql_executor "SET NAMES $META_DB_CHARSET;$sql" "$META_DB_URL"
            ;;
        $DB_TYPE_ORACLE)
            error "Unsupported database type $META_DB_TYPE"
            exit ${E_UNSUPPORTED_DB}
            ;;
        $DB_TYPE_POSTGRESQL)
            error "Unsupported database type $META_DB_TYPE"
            exit ${E_UNSUPPORTED_DB}
            ;;
        *)
            error "Unsupported database type $META_DB_TYPE"
            exit ${E_UNSUPPORTED_DB}
            ;;
    esac
}

# 更新任务
# 返回影响行数
function update_task()
{
    local task_id="$1"
    local run_time="$2"
    local updates="$3"

    echo "UPDATE t_task_pool SET $updates 
    WHERE task_id = $task_id 
    AND run_time = STR_TO_DATE('$run_time','%Y%m%d%H%i%s');
    SELECT ROW_COUNT();
    " | execute_meta
}

# 获取任务扩展属性
function get_task_ext()
{
    local task_id="$1"
    local excludes="$2"

    if [[ -n "$excludes" ]]; then
        local filter="AND prop_name NOT IN (excludes)"
    fi

    echo "SELECT CONCAT(prop_name,'=\"',IFNULL(prop_value,''),'\"') 
    FROM t_task_ext 
    WHERE task_id = '${task_id}' 
    $filter;
    " | execute_meta
}

# 获取数据库信息
function get_db()
{
    local db_id="$1"

    if [ -z "$db_id" ]; then
        error "Invalid arguments : get_db $@"
        return ${E_INVALID_ARGS}
    fi

    echo "SELECT b.code db_type,
    a.hostname,
    a.port,
    a.username,
    a.password,
    a.db_name,
    a.charset,
    c.code db_con_type 
    FROM t_db_con a 
    INNER JOIN t_db_type b 
    INNER JOIN t_db_con_type c 
    ON a.type_id = b.id 
    AND a.con_type_id = c.id 
    AND a.id = $db_id;
    " | execute_meta
}

# 任务步骤日志
function log_step()
{
    local level="$1"
    local content="$2"

    echo "INSERT INTO t_task_log (task_id,run_time,level,content) 
    VALUES ($task_id,STR_TO_DATE('$run_time','%Y%m%d%H%i%s'),$level,'$content');
    " | execute_meta
}

# 解析表名（简单/分表/动态）
function table_parser()
{
    local table_name="$1"
    local table_type="$2"

    case $table_type in
        $TABLE_TYPE_SIMPLE)
            echo $table_name
            ;;
        $TABLE_TYPE_SHARDING)
            local temp=${table_name#*{}
            range_num ${temp%\}*} | while read num; do
                echo ${table_name%{*}${num}
            done
            ;;
        $TABLE_TYPE_DYNAMIC)
            echo $table_name
            ;;
        *)
            error "Unsupported table type ${table_type}"
            exit ${E_UNSUPPORTED_TABLE_TYPE}
            ;;
    esac
}
