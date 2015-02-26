# 任务管理器工具类


source $SCHED_HOME/manager/config.sh


# 清理历史任务
# 状态为 "初始化","成功","失败" 的任务
function clear_task_history()
{
    echo "CREATE TABLE IF NOT EXISTS t_task_history LIKE t_task_pool;
    INSERT IGNORE INTO t_task_history 
    SELECT a.* FROM t_task_pool a INNER JOIN t_task b 
    ON a.task_id = b.id 
    AND a.task_state IN ($TASK_STATE_INITIAL,$TASK_STATE_SUCCESS,$TASK_STATE_FAILED) 
    AND ( 
        ( b.task_cycle = '$TASK_CYCLE_DAY' AND a.run_time < CURDATE() - INTERVAL $TASK_KEEP_DAY DAY ) 
        OR ( b.task_cycle = '$TASK_CYCLE_WEEK' AND a.run_time < CURDATE() - INTERVAL $TASK_KEEP_WEEK WEEK ) 
        OR ( b.task_cycle = '$TASK_CYCLE_MONTH' AND a.run_time < CURDATE() - INTERVAL $TASK_KEEP_MONTH MONTH ) 
        OR ( b.task_cycle = '$TASK_CYCLE_HOUR' AND a.run_time < CURDATE() - INTERVAL $TASK_KEEP_HOUR HOUR ) 
        OR ( b.task_cycle = '$TASK_CYCLE_INTERVAL' AND a.run_time < CURDATE() - INTERVAL $TASK_KEEP_INTERVAL * b.cycle_value MINUTE ) 
    );

    DELETE a.* FROM t_task_pool a INNER JOIN t_task b 
    ON a.task_id=b.id 
    AND a.task_state IN ($TASK_STATE_INITIAL,$TASK_STATE_SUCCESS,$TASK_STATE_FAILED) 
    AND ( 
        ( b.task_cycle = '$TASK_CYCLE_DAY' AND a.run_time < CURDATE() - INTERVAL $TASK_KEEP_DAY DAY ) 
        OR ( b.task_cycle = '$TASK_CYCLE_WEEK' AND a.run_time < CURDATE() - INTERVAL $TASK_KEEP_WEEK WEEK ) 
        OR ( b.task_cycle = '$TASK_CYCLE_MONTH' AND a.run_time < CURDATE() - INTERVAL $TASK_KEEP_MONTH MONTH ) 
        OR ( b.task_cycle = '$TASK_CYCLE_HOUR' AND a.run_time < CURDATE() - INTERVAL $TASK_KEEP_HOUR HOUR ) 
        OR ( b.task_cycle = '$TASK_CYCLE_INTERVAL' AND a.run_time < CURDATE() - INTERVAL $TASK_KEEP_INTERVAL * b.cycle_value MINUTE ) 
    );
    " | execute_meta
}

# 获取配置任务
function get_tasks()
{
    echo "SELECT 
    a.id task_id,
    a.task_cycle,
    IF (
        a.cycle_value > '',
        a.cycle_value,
        NULL
    ) cycle_value,
     DATE_FORMAT(
        IF (
            b.run_time IS NULL,
            a.start_time,
            MAX(
                CASE a.task_cycle 
                WHEN '$TASK_CYCLE_DAY' THEN b.run_time + INTERVAL 1 DAY 
                WHEN '$TASK_CYCLE_WEEK' THEN b.run_time + INTERVAL 1 WEEK 
                WHEN '$TASK_CYCLE_MONTH' THEN b.run_time + INTERVAL 1 MONTH 
                WHEN '$TASK_CYCLE_HOUR' THEN b.run_time + INTERVAL 1 HOUR 
                END 
            )
        ),
        '%Y%m%d%H%i%s'
    ) start_time,
     DATE_FORMAT(
        IF (
            a.end_time < NOW(),
            a.end_time,
            NOW()
        ),
        '%Y%m%d%H%i%s'
    ) end_time,
    a.date_serial,
    a.priority,
    a.max_try_times 
    FROM t_task a 
    LEFT JOIN t_task_pool b 
    ON a.id = b.task_id 
    WHERE a.task_status = $TASK_STATUS_NORMAL 
    AND a.start_time < NOW() 
    AND a.task_cycle IN ( '$TASK_CYCLE_DAY', '$TASK_CYCLE_WEEK', '$TASK_CYCLE_MONTH', '$TASK_CYCLE_HOUR' ) 
    GROUP BY 1;
    " | execute_meta
}

# 获取初始状态任务
function get_initial_tasks()
{
    echo "SELECT 
    a.task_id,
    DATE_FORMAT(a.run_time, '%Y%m%d%H%i%s') run_time,
    b.task_cycle,
    IF (
        b.cycle_value > '',
        b.cycle_value,
        NULL
    ) cycle_value,
    DATE_FORMAT(
        b.start_time,
        '%Y%m%d%H%i%s'
    ) start_time,
    b.date_serial 
    FROM t_task_pool a 
    INNER JOIN t_task b 
    ON a.task_id = b.id 
    AND a.task_state = $TASK_STATE_INITIAL;
    " | execute_meta
}

# 获取相对于某个日期所在的周期
function get_current_cycle()
{
    local the_time="$1"
    local task_cycle="$2"
    local cycle_value="$3"

    local the_date=${the_time:0:8}
    local current_cycle

    case $task_cycle in
        $TASK_CYCLE_DAY)
            current_cycle=$the_date
            ;;
        $TASK_CYCLE_WEEK)
            local week_num=`date +%w -d "$the_date"`
            week_num=$((week_num > 0 ? week_num : 7))
            week_num=$((cycle_value - week_num))
            current_cycle=`date +%Y%m%d -d "$the_date $week_num day"`
            ;;
        $TASK_CYCLE_MONTH)
            local the_month=`date +%Y%m -d "$the_date"`
            current_cycle=${the_month}$cycle_value
            ;;
        $TASK_CYCLE_HOUR)
            current_cycle=${the_time:0:10}
            ;;
        *)
            error "Unsupported task cycle: $task_cycle"
            exit ${E_UNSUPPORTED_TASK_CYCLE}
        ;;
    esac

    echo $current_cycle
}

# 获取 上/下 一个周期
function get_next_cycle()
{
    local the_time="$1"
    local task_cycle="$2"
    local flag="$3"

    local the_cycle

    case $task_cycle in
        $TASK_CYCLE_DAY|$TASK_CYCLE_WEEK|$TASK_CYCLE_MONTH)
            the_cycle=`date +%Y%m%d -d "${the_time:0:8} 1 $task_cycle $flag"`
            ;;
        $TASK_CYCLE_HOUR)
            the_cycle=`date +%Y%m%d%H -d "${the_time:0:8} ${the_time:8:2} 1 hour $flag"`
            ;;
        *)
            error "Unsupported task cycle: $task_cycle"
            exit ${E_UNSUPPORTED_TASK_CYCLE}
            ;;
    esac

    echo $the_cycle
}

# 获取周期边界
function get_cycle_range()
{
    local start_time="$1"
    local end_time="$2"
    local task_cycle="$3"
    local cycle_value="$4"

    local first_cycle=$(get_current_cycle $start_time $task_cycle $cycle_value)
    local last_cycle=$(get_current_cycle $end_time $task_cycle $cycle_value)

    case $task_cycle in
        $TASK_CYCLE_DAY|$TASK_CYCLE_WEEK|$TASK_CYCLE_MONTH)
            first_cycle=${first_cycle}${start_time:8:6}
            last_cycle=${last_cycle}${start_time:8:6}
            ;;
        $TASK_CYCLE_HOUR)
            first_cycle=${first_cycle}${start_time:10:4}
            last_cycle=${last_cycle}${start_time:10:4}
            ;;
        *)
            error "Unsupported task cycle: $task_cycle"
            exit ${E_UNSUPPORTED_TASK_CYCLE}
            ;;
    esac

    if [[ $first_cycle -lt $start_time ]]; then
        first_cycle=$(get_next_cycle $first_cycle $task_cycle)
    fi

    if [[ $last_cycle -gt $end_time ]]; then
        last_cycle=$(get_next_cycle $last_cycle $task_cycle ago)
    fi

    case $task_cycle in
        $TASK_CYCLE_DAY|$TASK_CYCLE_WEEK|$TASK_CYCLE_MONTH)
            first_cycle=${first_cycle:0:8}
            last_cycle=${last_cycle:0:8}
            ;;
        $TASK_CYCLE_HOUR)
            first_cycle=${first_cycle:0:10}
            last_cycle=${last_cycle:0:10}
            ;;
    esac

    echo $first_cycle $last_cycle
}

# 获取 第一个/最后一个 周期
function get_first_cycle()
{
    local start_time="$1"
    local task_cycle="$2"
    local cycle_value="$3"

    local first_cycle=$(get_current_cycle $start_time $task_cycle $cycle_value)

    case $task_cycle in
        $TASK_CYCLE_DAY|$TASK_CYCLE_WEEK|$TASK_CYCLE_MONTH)
            first_cycle=${first_cycle}${start_time:8:6}
            ;;
        $TASK_CYCLE_HOUR)
            first_cycle=${first_cycle}${start_time:10:4}
            ;;
        *)
            error "Unsupported task cycle: $task_cycle"
            exit ${E_UNSUPPORTED_TASK_CYCLE}
            ;;
    esac

    if [[ $first_cycle -lt $start_time ]]; then
        first_cycle=$(get_next_cycle $first_cycle $task_cycle)
    fi

    case $task_cycle in
        $TASK_CYCLE_DAY|$TASK_CYCLE_WEEK|$TASK_CYCLE_MONTH)
            first_cycle=${first_cycle:0:8}"000000"
            ;;
        $TASK_CYCLE_HOUR)
            first_cycle=${first_cycle:0:10}"0000"
            ;;
    esac

    echo $first_cycle
}

# 生成任务实例
function make_task_instance()
{
    local task_id="$1"
    local task_cycle="$2"
    local cycle_value="$3"
    local start_time="$4"
    local end_time="$5"

    # 获取任务周期边界
    local cycle_range=($(get_cycle_range $start_time $end_time $task_cycle $cycle_value))
    start_time=${cycle_range[0]}
    end_time=${cycle_range[1]}

    local start_date=${start_time:0:8}
    local end_date=${end_time:0:8}

    case $task_cycle in
        $TASK_CYCLE_DAY)
            range_date $start_date $end_date | while read the_day; do
                echo $task_id $the_day
            done
            ;;
        $TASK_CYCLE_WEEK)
            range_week $start_date $end_date extend | while read the_week week_begin week_end; do
                week_num=$((cycle_value - 1))
                the_day=`date +%Y%m%d -d "$week_begin $week_num day"`
                echo $task_id $the_day
            done
            ;;
        $TASK_CYCLE_MONTH)
            range_date ${start_date:0:6} ${end_date:0:6} | while read the_month; do
                the_day=`date +%Y%m%d -d "${the_month}${cycle_value}"`
                echo $task_id $the_day
            done
            ;;
        $TASK_CYCLE_HOUR)
            range_date ${start_time:0:10} ${end_time:0:10} | while read the_time; do
                echo $task_id $the_time
            done
            ;;
        *)
            error "Unsupported task cycle: $task_cycle"
            exit ${E_UNSUPPORTED_TASK_CYCLE}
            ;;
    esac
}

# 生成任务周期
function range_cycle()
{
    local start_time="$1"
    local end_time="$2"
    local task_cycle="$3"
    local cycle_value="$4"

    case $task_cycle in
        $TASK_CYCLE_DAY)
            range_date $start_time $end_time
            ;;
        $TASK_CYCLE_WEEK)
            range_week $start_time $end_time extend | while read week_num week_start week_end; do
                week_num=$((cycle_value - 1))
                the_day=`date +%Y%m%d -d "$week_start $week_num day"`
                if [[ $the_day -ge $start_time && $the_day -le $end_time ]]; then
                    echo $the_day
                fi
            done
            ;;
        $TASK_CYCLE_MONTH)
            local month_start=`date +%Y%m -d "$start_time"`
            local month_end=`date +%Y%m -d "$end_time"`
            range_date $month_start $month_end | while read the_month; do
                the_day=${the_month}$cycle_value
                if [[ $the_day -ge $start_time && $the_day -le $end_time ]]; then
                    echo $the_day
                fi
            done
            ;;
        $TASK_CYCLE_HOUR)
            range_date $start_time $end_time
            ;;
    esac
}

# 获取任务状态
function get_task_state()
{
    local task_id="$1"
    local run_time="$2"

    echo "SELECT task_state 
    FROM t_task_pool 
    WHERE task_id = $task_id 
    AND run_time = STR_TO_DATE('$run_time','%Y%m%d%H%i%s');
    " | execute_meta
}

# 检查全周期
function check_full_cycle()
{
    local task_id="$1"
    local task_cycle="$2"
    local cycle_value="$3"
    local start_time="$4"
    local end_time="$5"

    range_cycle $start_time $end_time $task_cycle $cycle_value | tac | while read the_time; do
        task_state=$(get_task_state $task_id $the_time)
        if [[ $task_state -ne $TASK_STATE_SUCCESS ]]; then
            echo $task_state
            break
        fi
    done
}

# 获取依赖任务
function get_task_link()
{
    local task_id="$1"

    echo "SELECT a.task_pid,
    a.link_type,
    b.task_cycle,
    b.cycle_value,
    IF(
        b.task_cycle = '$TASK_CYCLE_HOUR',
        DATE_FORMAT(b.start_time,'%Y%m%d%H'),
        DATE_FORMAT(b.start_time,'%Y%m%d')
    ) start_time,
    IF(
        b.task_cycle = '$TASK_CYCLE_HOUR',
        DATE_FORMAT(IFNULL(b.end_time,NOW()),'%Y%m%d%H'),
        DATE_FORMAT(IFNULL(b.end_time,NOW()),'%Y%m%d')
    ) end_time 
    FROM t_task_link a 
    INNER JOIN t_task b 
    ON a.task_pid = b.id 
    AND a.task_id = $task_id;
    " | execute_meta
}

# 检查任务依赖
# 1、自身依赖
#   a、不是第一个运行周期
#   b、上一个运行周期任务成功
# 2、父子依赖
#   2.1、日任务依赖日任务
#     a、当天任务成功
#   2.2、周任务依赖日任务（全周期依赖）
#     a、从上周二截止当天的任务全部成功
#   2.3、周任务依赖日任务（最后一个周期依赖）
#     a、当天任务成功
#   2.4、月任务依赖日任务（全周期依赖）
#     a、从上个月2号截止当天的任务全部成功
#   2.5、月任务依赖日任务（最后一个周期依赖）
#     a、当天任务成功
#   2.6、周任务依赖周任务
#     a、本周任务成功
#   2.7、月任务依赖月任务
#     a、本月任务成功
#   2.8、小时任务依赖小时任务
#     a、当前小时任务成功
function check_dependence()
{
    local task_id="$1"
    local run_time="$2"
    local task_cycle="$3"
    local cycle_value="$4"
    local start_time="$5"
    local date_serial="$6"

    # 任务类型为 "时间间隔",不支持依赖
    if [[ "$task_cycle" = "$TASK_CYCLE_INTERVAL" ]]; then
        return
    fi

    # 自身依赖
    # 运行时间大于第一个运行周期
    local first_cycle=$(get_first_cycle $start_time $task_cycle $cycle_value)
    if [[ $run_time -gt $first_cycle && $date_serial -eq $DATE_SERIAL ]]; then
        # 检查上一个周期的状态
        local last_cycle=$(get_next_cycle $run_time $task_cycle ago)
        local task_state=$(get_task_state $task_id $last_cycle)
        if [[ $task_state -ne $TASK_STATE_SUCCESS ]]; then
            echo $task_state
            return
        fi
    fi

    # 父子依赖
    get_task_link $task_id | while read p_task_id link_type p_task_cycle p_cycle_value p_start_time p_end_time; do
        case $link_type in
            # 全周期依赖
            $LINK_TYPE_FULL)
                case $task_cycle in
                    # 任务周期为 天
                    $TASK_CYCLE_DAY)
                        case $p_task_cycle in
                            # 父任务周期为 天
                            $TASK_CYCLE_DAY)
                                task_state=$(get_task_state $p_task_id $run_time)
                                ;;
                            # 父任务周期为 周,月,小时
                            *)
                                # 不支持
                                ;;
                        esac
                        ;;
                    # 任务周期为 周
                    $TASK_CYCLE_WEEK)
                        case $p_task_cycle in
                            # 父任务周期为 天
                            $TASK_CYCLE_DAY)
                                # 本周二
                                local cur_tuesday=$(get_current_cycle $run_time $TASK_CYCLE_WEEK 2)
                                # 上周二
                                local last_tuesday=$(date +%Y%m%d -d "$cur_tuesday 1 week ago")
                                if [[ $p_start_time -gt $last_tuesday ]]; then
                                    last_tuesday=$p_start_time
                                fi
                                task_state=$(check_full_cycle $p_task_id $p_task_cycle $p_cycle_value $last_tuesday ${run_time:0:8})
                                ;;
                            # 父任务周期为 周
                            $TASK_CYCLE_WEEK)
                                local current_cycle=$(get_current_cycle $run_time $p_task_cycle $p_cycle_value)
                                task_state=$(get_task_state $p_task_id $current_cycle)
                                ;;
                            # 父任务周期为 月,小时
                            *)
                                # 不支持
                                ;;
                        esac
                        ;;
                    # 任务周期为 月
                    $TASK_CYCLE_MONTH)
                        case $p_task_cycle in
                            # 父任务周期为 天
                            $TASK_CYCLE_DAY)
                                # 本月2号
                                local cur_2nd=$(get_current_cycle $run_time $TASK_CYCLE_MONTH 02)
                                # 上个月2号
                                local last_2nd=$(date +%Y%m%d -d "$cur_2nd 1 month ago")
                                if [ $p_start_time -gt $last_2nd ]; then
                                    last_2nd=$p_start_time
                                fi
                                task_state=$(check_full_cycle $p_task_id $p_task_cycle $p_cycle_value $last_2nd ${run_time:0:8})
                                ;;
                            # 父任务周期为 月
                            $TASK_CYCLE_MONTH)
                                current_cycle=$(get_current_cycle $run_time $p_task_cycle $p_cycle_value)
                                task_state=$(get_task_state $p_task_id $current_cycle)
                                ;;
                            # 父任务周期为 周,小时
                            *)
                                # 不支持
                                ;;
                        esac
                        ;;
                    # 任务周期为 小时
                    $TASK_CYCLE_HOUR)
                        case $p_task_cycle in
                            # 父任务周期为 小时
                            $TASK_CYCLE_HOUR)
                                task_state=$(get_task_state $p_task_id $run_time)
                                ;;
                            *)
                                # 不支持
                                ;;
                        esac
                        ;;
                esac
                # 判断任务状态，非成功则退出
                if [[ -n "$task_state" && "$task_state" -ne $TASK_STATE_SUCCESS ]]; then
                    echo $task_state
                    break
                fi
                ;;
            # 最后一个周期依赖
            $LINK_TYPE_LAST)
                current_cycle=$(get_current_cycle $run_time $p_task_cycle $p_cycle_value)
                task_state=$(get_task_state $p_task_id $current_cycle)
                if [[ "$task_state" -ne $TASK_STATE_SUCCESS ]]; then
                    echo $task_state
                    break
                fi
                ;;
            # 任意一个周期依赖
            $LINK_TYPE_ANY)
                ;;
        esac
    done
}

# 实例化任务
function insert_task()
{
    if [ $# -ne 5 ]; then
        error "Invalid arguments : insert_task $@"
        exit ${E_INVALID_ARGS}
    fi

    local task_id="$1"
    local run_time="$2"
    local task_state="$3"
    local priority="$4"
    local max_try_times="$5"

    echo "INSERT IGNORE INTO t_task_pool (task_id,run_time,task_state,priority,max_try_times,create_time) 
    VALUES ($task_id,STR_TO_DATE('$run_time','%Y%m%d%H%i%s'),$task_state,$priority,$max_try_times,NOW());
    " | execute_meta
}
