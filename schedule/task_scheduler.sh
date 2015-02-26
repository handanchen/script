#!/bin/bash

# 任务调度器
# 1、扫描任务周期为时间间隔的任务
# 2、扫描任务状态为就绪的任务
# 3、根据任务的优先级进行调度


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


# 初始化
# 创建目录
mkdir -p ${meta_sql_log_path} 2> /dev/null
mkdir -p ${task_log_path} 2> /dev/null
mkdir -p ${task_tmp_path} 2> /dev/null
mkdir -p ${task_data_path} 2> /dev/null


# 初始化时间间隔任务
function init_task_interval()
{
    get_task_interval $task_type_list | while read task_id task_type_id cycle_value; do
        # 判断任务是否已经启动
        count=`count_thread "common/util/timer.sh sh scanner/task_starter.sh $task_id"`
        if [ $count -eq 0 ]; then
            # 启动定时器
            nohup sh common/util/timer.sh "sh scanner/task_starter.sh $task_id" $cycle_value > ${task_log_path}/${task_id}.$(cur_datetime).info 2> ${task_log_path}/${task_id}.$(cur_datetime).error &
        fi
    done
}

# 初始化就绪任务
function init_task_ready()
{
    get_task_ready $task_type_list | while read task_id run_time task_type_id max_thread_count task_runner; do
        # 判断任务是否超过最大并发数
        # 获取正在运行的任务数
        run_task_count=$(count_task_run $task_type_id)
        if [ $run_task_count -lt $max_thread_count ]; then
        # 更新任务状态为正在运行、运行服务器为本机
        row_count=$(update_task $task_id $run_time "state=$task_state_running,run_server=$server_id,start_time=now(),tried_times=tried_times+1")
            if [ $row_count -gt 0 ]; then
                # 启动任务
                nohup sh $task_runner $task_id $run_time $task_type_id > ${task_log_path}/${task_id}.${run_time}.info 2> ${task_log_path}/${task_id}.${run_time}.error &
            fi
        fi
    done
}

# 执行操作
function execute()
{
    while :; do
        log_fn init_task_interval
        log_fn init_task_ready
        sleep $task_scan_interval
    done
}

function main()
{
    execute
}
main
