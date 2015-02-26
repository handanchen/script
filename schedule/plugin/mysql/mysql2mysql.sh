#!/bin/bash
#
# mysql到mysql数据同步


BASE_DIR=`pwd`
REL_DIR=`dirname $0`
cd $REL_DIR
DIR=`pwd`
cd - > /dev/null


source $SHELL_HOME/common/include.sh
source $SHELL_HOME/common/date_util.sh
source $SHELL_HOME/common/db/config.sh
source $SHELL_HOME/common/db/mysql/mysql_util.sh
source $SHELL_HOME/common/db/mysql/mysql2mysql.sh
source $SCHED_HOME/common/task_util.sh


# 生成表
function build_table()
{
    # 创建表
    case $create_table in
        $CMD_CREATE_AUTO)
            create_table
            ;;
        $CMD_CREATE_DROP)
            mysql_executor "DROP TABLE IF EXISTS $tar_table;" "$tar_db_url" && create_table
            ;;
        *)
            ;;
    esac
}

# 预装载
function pre_load()
{
    # 装载模式
    case $load_mode in
        $LOAD_MODE_IGNORE)
            load_mode=ignore
            ;;
        $LOAD_MODE_APPEND)
            load_mode=""
            ;;
        $LOAD_MODE_REPLACE)
            load_mode=replace
            ;;
        $LOAD_MODE_TRUNCATE)
            load_mode=""
            mysql_executor "TRUNCATE TABLE $tar_table;" "$tar_db_url"
            ;;
        *)
            ;;
    esac
}

# 导出数据
function export_data()
{
    # 构建查询sql语句
    local sql="SET NAMES $src_db_charset;SELECT $src_columns FROM $src_table WHERE 1 = 1 $src_filter $page_filter"
    # 执行sql语句
    mysql_executor "$sql" "$src_db_url" > ${TASK_DATA_PATH}/${src_table}_${page_no}.tmp
}

# 装载数据
function load_data()
{
    # 生成装载sql语句
    load_sql="SET NAMES $tar_db_charset;"`build_load_sql`
    # 执行sql语句
    mysql_executor "$load_sql" "$tar_db_url -vvv" > ${TASK_LOG_PATH}/${tar_table}.log
}

# 同步一页
# Globals:
# Arguments:
# Returns:
function sync_page()
{
    # 抽取数据
    export_data

    # 装载数据
    load_data
}

# 同步数据
# Globals:
# Arguments:
# Returns:
function sync_data()
{
    # 生成表
    build_table

    # 预装载数据
    pre_load

    # 分页同步
    local total_count=$(mysql_executor "SELECT COUNT(*) FROM $src_table WHERE 1=1 $src_filter" "$src_db_url")
    local total_page=$((total_count % page_size == 0 ? total_count / page_size : total_count / page_size + 1))

    for((page_no=1;page_no<=$total_page;page_no++)); do
        offset=$(((page_no-1) * page_size))
        page_filter="$src_filter LIMIT $offset,${page_size}"

        sync_page
    done
}

function execute()
{
    # 创建目录
    mkdir -p ${TASK_TMP_PATH}

    # 获取任务属性
    get_task_ext $task_id > ${TASK_TMP_PATH}/${task_id}.props
    source ${TASK_TMP_PATH}/${task_id}.props

    # 获取源服务器信息
    src_db=($(get_db $src_db_id))
    # 源数据库连接字符串
    src_db_url=$(make_mysql_url "${src_db[1]}" "${src_db[3]}" "${src_db[4]}" "${src_db[5]}" "${src_db[2]}")
    # 源数据库编码
    src_db_charset=${src_db[6]}

    # 获取目标服务器信息
    tar_db=($(get_db $tar_db_id))
    # 目标数据库连接字符串
    tar_db_url=$(make_mysql_url "${tar_db[1]}" "${tar_db[3]}" "${tar_db[4]}" "${tar_db[5]}" "${tar_db[2]}")
    # 数据库编码
    tar_db_charset=${tar_db[6]}

    # 增量条件
    if [[ -n "$src_time_columns" ]]; then
        time_filter=`echo "$src_time_columns" | awk -F"," '{
            printf(" AND ")
            for(i=1;i<=NF;i++){
                printf("( %s >= '$prev_day' AND %s < '$the_day' ) OR ",$i,$i)
            }
        }' | sed 's/ OR $//'`
        src_filter="$time_filter $src_filter"
    fi

    # 分页大小
    page_size=${page_size:-$PAGE_SIZE}

    # 解析表名
    task_state=`table_parser "$src_table" $src_table_type | while read src_table; do
        # 目标表名
        tar_table=${tar_table:-$src_table}
        sync_data > ${TASK_LOG_PATH}/${task_id}.${run_time}.info 2> ${TASK_LOG_PATH}/${task_id}.${run_time}.error
        # 执行结果判断，出错则退出
        if [[ $? -ne 0 ]]; then
            echo $TASK_STATE_FAILED
            break
        fi
    done`

    # 判断任务执行结果
    if [[ -z "$task_state" ]]; then
        task_state=$TASK_STATE_SUCCESS
    elif [[ $task_state -eq $TASK_STATE_FAILED ]]; then
        # 记录错误日志
        log_step $LOG_LEVEL_ERROR "`cat ${TASK_LOG_PATH}/${task_id}.${run_time}.error | mysql_escape`"
    fi

    # 更新任务，状态、结束时间
    update_task $task_id $run_time "task_state = $task_state, end_time = NOW()"
}

function main()
{
    task_id="$1"
    run_time="$2"

    init_date ${run_time:0:8}

    execute
}
main "$@"
