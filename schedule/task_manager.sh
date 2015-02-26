#!/bin/bash

# 任务管理器
# 1、清理任务池历史任务
# 2、实例化任务到任务池
# 3、检查状态为“等待”的任务的依赖关系，满足条件则更新状态为“就绪”


BASE_DIR=`pwd`
REL_DIR=`dirname $0`
cd $REL_DIR
DIR=`pwd`
cd - > /dev/null


source $SHELL_HOME/common/include.sh
source $SHELL_HOME/common/date_util.sh
source $SHELL_HOME/common/db/config.sh
source $SHELL_HOME/common/db/mysql/mysql_util.sh
source $SCHED_HOME/common/task_util.sh
source $SCHED_HOME/manager/manage_util.sh


# 清理任务池历史任务
# 每天清理一次，清理成功后会生成一个空的flag文件
function clear_task_pool()
{
    local cur_date=$(cur_date)

    # 创建目录如果不存在
    info "Create dir: $TASK_LOG_PATH if not exists"
    mkdir -p $TASK_LOG_PATH

    info "Check if exists flag file: $TASK_LOG_PATH/task_pool_clear_flag.$cur_date"
    if [[ ! -f $TASK_LOG_PATH/task_pool_clear_flag.$cur_date ]]; then

        # 删除历史文件
        info "Delete history flag files if exists"
        rm -f $TASK_LOG_PATH/task_pool_clear_flag.*

        # 清理历史任务，并生成flag文件
        info "Clear history tasks from task pool and generate flag file: $TASK_LOG_PATH/task_pool_clear_flag.$cur_date"
        clear_task_history && touch $TASK_LOG_PATH/task_pool_clear_flag.$cur_date
    fi
}

# 实例化任务
function init_task()
{
    info "Get tasks and instantiate one by one"
    get_tasks | while read task_id task_cycle cycle_value start_time end_time date_serial priority max_try_times; do

        debug "Begin instantiate task: (task_id, task_cycle, cycle_value, start_time, end_time) ($task_id, $task_cycle, $cycle_value, $start_time, $end_time)"
        make_task_instance $task_id $task_cycle $cycle_value $start_time $end_time | while read task_id run_time; do

            debug "Insert task: (task_id, run_time, task_state, priority, max_try_times) ($task_id, $run_time, $TASK_STATE_INITIAL, $priority, $max_try_times)"
            insert_task $task_id $run_time $TASK_STATE_INITIAL $priority $max_try_times
        done
    done
}

# 检查状态为“等待”的任务的依赖关系
function check_task_deps()
{
    info "Get initial tasks and check one by one"
    get_initial_tasks | while read task_id run_time task_cycle cycle_value start_time date_serial; do

        debug "Begin check task: (task_id, run_time, task_cycle, cycle_value, start_time, date_serial) ($task_id, $run_time, $task_cycle, $cycle_value, $start_time, $date_serial)"
        task_state=$(check_dependence $task_id $run_time $task_cycle $cycle_value $start_time $date_serial)

        debug "Done check task: (task_id, run_time) ($task_id, $run_time) task_state=$task_state"
        if [[ -z "$task_state" ]]; then
            debug "Update task: (task_id, run_time) ($task_id, $run_time) set task_state=\$TASK_STATE_READY"
            update_task $task_id $run_time "task_state = $TASK_STATE_READY" > /dev/null
        fi
    done
}

# 执行操作
function execute()
{
    info "Clear history tasks from task pool start"
    clear_task_pool
    info "Clear history tasks from task pool done"

    info "Make tasks instances start"
    init_task
    info "Make tasks instances done"

    info "Check initial tasks dependences start"
    check_task_deps
    info "Check initial tasks dependences done"
}

function main()
{
    if [[ "$1" = "$CMD_STAY" ]]; then
        shift
        while :; do
            execute

            info "$0 sleep for $TASK_CHECK_INTERVAL"
            sleep $TASK_CHECK_INTERVAL
            info "$0 wake up"
        done
    else
        execute
    fi
}
main "$@"
