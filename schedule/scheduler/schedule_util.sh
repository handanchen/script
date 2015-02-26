# 任务调度器工具


source $SCHED_HOME/scheduler/config.sh


# 获取时间间隔任务
function get_task_interval()
{
    local task_type_list="$1"

    if [ -n "$task_type_list" ]; then
        local filter="AND type_id IN ($task_type_list)"
    fi

    echo "SELECT id, cycle_value 
    FROM t_task 
    WHERE task_status = $TASK_STATUS_NORMAL 
    AND start_time <= NOW() 
    AND (
        end_time >= NOW()
        OR end_time IS NULL
    )
    AND task_cycle = '$TASK_CYCLE_INTERVAL' 
    AND CURTIME() >= CAST( start_time AS TIME ) 
    AND (
        CURTIME() <= CAST( end_time AS TIME )
        OR CAST( end_time AS TIME ) = 0
        OR end_time IS NULL
    )
    $filter;
    " | execute_meta
}

# 获取子任务
function get_task_children()
{
    local task_id="$1"

    echo "SELECT task_id FROM t_task_link WHERE task_pid = $task_id;" | execute_meta
}

# 获取就绪任务
function get_task_ready()
{
    local task_type_list="$1"

    if [ -n "$task_type_list" ]; then
        local filter="WHERE type_id IN ($task_type_list)"
    fi

    echo "SELECT 
    a.task_id,
    DATE_FORMAT(a.run_time, '%Y%m%d%H%i%s') run_time,
    b.type_id 
    FROM t_task_pool a 
    INNER JOIN t_task b 
    ON a.task_id = b.id 
    AND a.task_state IN ( $TASK_STATE_READY, $TASK_STATE_FAILED ) 
    AND a.tried_times < a.max_try_times
    $filter 
    ORDER BY a.priority;
    " | execute_meta
}

# 获取正在运行的任务数
function count_task_run()
{
    local type_id="$1"

    if [ -n "$task_type_id" ]; then
        local filter="AND b.type_id = $type_id"
    fi

    echo "SELECT COUNT(1) 
    FROM t_task_pool a 
    INNER JOIN t_task b 
    ON a.task_id=b.id
    AND a.task_state = $TASK_STATE_RUNNING 
    AND a.run_server = $server_id 
    $filter;
    " | execute_meta
}

# 获取任务信息
function get_task()
{
    local task_id="$1"

    echo "SELECT a.type_id,
    a.priority,
    a.max_try_times,
    b.task_runner
    FROM t_task a 
    INNER JOIN t_task_type b 
    ON a.type_id = b.id 
    AND a.id = $task_id;
    " | execute_meta
}
