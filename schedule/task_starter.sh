#!/bin/sh

# 任务启动器
# 1、启动任务周期为时间间隔的任务


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
source $SCHED_HOME/scheduler/schedule_util.sh


# 运行时间间隔任务
function run_task_interval()
{
    local task_id="$1"

    # 获取任务信息
    local task=($(get_task $task_id))

    # 实例化任务
    local cur_time=$(cur_datetime)
    local run_time=${cur_time:0:12}

    echo "INSERT IGNORE INTO t_task_pool (task_id,run_time,task_state,priority,max_try_times,tried_times,run_server,begin_time,create_time) 
    VALUES ($task_id,STR_TO_DATE('$run_time','%Y%m%d%H%i%s'),$TASK_STATE_RUNNING,${task[1]},${task[2]},1,$server_id,NOW(),NOW());
    " | execute_meta

    # 启动任务
    sh ${task[3]} $task_id $run_time ${task[0]} > ${task_log_path}/${task_id}.${run_time}.info 2> ${task_log_path}/${task_id}.${run_time}.error
}

# 执行子任务
function run_task_children()
{
    get_task_children | while read task_id; do
        run_task_interval $task_id
    done
}

function execute()
{
    run_task_interval $task_id
    run_task_children
}

function main()
{
    task_id="$1"

    execute
}
main "$@"
