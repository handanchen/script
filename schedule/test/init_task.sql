-- 初始化任务配置信息

USE schedule;

TRUNCATE TABLE t_task;
TRUNCATE TABLE t_task_link;

CREATE TABLE IF NOT EXISTS t_task_history LIKE t_task_pool;
TRUNCATE TABLE t_task_history;
INSERT IGNORE INTO t_task_history SELECT * FROM t_task_pool;
TRUNCATE TABLE t_task_pool;

SET @task_type_id=1;
SET @not_serial=0;
SET @date_serial=1;
SET @create_user='zhangchao';
SET @create_time=NOW();
SET @the_time='23:59:59';
SET @week_num=IF(DAYOFWEEK(NOW()) > 1, DAYOFWEEK(NOW()) - 1, 7);

INSERT INTO t_task ( task_name, type_id, description, task_cycle, cycle_value, date_serial, start_time, end_time, create_user, create_time ) VALUES 
( '日任务1', @task_type_id, '不串行，无依赖', 'day', NULL, @not_serial, NOW()-INTERVAL 3 MONTH, NULL, @create_user, @create_time ),
( '日任务2', @task_type_id, '串行，无依赖', 'day', NULL, @date_serial, NOW()-INTERVAL 5 DAY, NOW()-INTERVAL 1 DAY, @create_user, @create_time ),
( '日任务3', @task_type_id, '不串行，全周期依赖日任务', 'day', NULL, @not_serial, NOW()-INTERVAL 3 DAY, NULL, @create_user, @create_time ),
( '日任务4', @task_type_id, '不串行，最后一个周期依赖日任务', 'day', NULL, @not_serial, NOW()-INTERVAL 3 DAY, NULL, @create_user, @create_time ),
( '周任务1', @task_type_id, '不串行，无依赖', 'week', '3', @not_serial, NOW()-INTERVAL 5 WEEK, NULL, @create_user, @create_time ),
( '周任务2', @task_type_id, '串行，无依赖', 'week', '2', @date_serial, NOW()-INTERVAL 5 WEEK, NOW()-INTERVAL 1 WEEK, @create_user, @create_time ),
( '周任务3', @task_type_id, '不串行，全周期依赖日任务', 'week', '3', @not_serial, NOW()-INTERVAL 3 WEEK, NULL, @create_user, @create_time ),
( '周任务4', @task_type_id, '不串行，最后一个周期依赖日任务', 'week', '3', @not_serial, NOW()-INTERVAL 3 WEEK, NULL, @create_user, @create_time ),
( '周任务5', @task_type_id, '不串行，全周期依赖周任务', 'week', '2', @not_serial, NOW()-INTERVAL 3 WEEK, NULL, @create_user, @create_time ),
( '周任务6', @task_type_id, '不串行，最后一个周期依赖周任务', 'week', '2', @not_serial, NOW()-INTERVAL 3 WEEK, NULL,@create_user, @create_time ),
( '月任务1', @task_type_id, '不串行，无依赖', 'month', '05', @not_serial, NOW()-INTERVAL 3 MONTH, NULL, @create_user, @create_time ),
( '月任务2', @task_type_id, '串行，无依赖', 'month', '08', @date_serial, NOW()-INTERVAL 5 MONTH, NOW()-INTERVAL 1 MONTH, @create_user, @create_time ),
( '月任务3', @task_type_id, '不串行，全周期依赖日任务', 'month', '07', @not_serial, NOW()-INTERVAL 3 MONTH, NULL, @create_user, @create_time ),
( '月任务4', @task_type_id, '不串行，最后一个周期依赖日任务', 'month', '07', @not_serial, NOW()-INTERVAL 3 MONTH, NULL, @create_user, @create_time ),
( '月任务5', @task_type_id, '不串行，全周期依赖月任务', 'month', '10', @not_serial, NOW()-INTERVAL 3 MONTH, NULL, @create_user, @create_time ),
( '月任务6', @task_type_id, '不串行，最后一个周期依赖月任务', 'month', '10', @not_serial, NOW()-INTERVAL 3 MONTH, NULL, @create_user, @create_time ),
( '小时任务1', @task_type_id, '不串行，无依赖', 'hour', NULL, @not_serial, NOW()-INTERVAL 1 DAY, NULL, @create_user, @create_time ),
( '小时任务2', @task_type_id, '串行，无依赖', 'hour', NULL, @date_serial, NOW()-INTERVAL 5 HOUR, NOW()-INTERVAL 1 HOUR, @create_user, @create_time ),
( '小时任务3', @task_type_id, '不串行，全周期依赖小时任务', 'hour', NULL, @not_serial, NOW()-INTERVAL 3 HOUR, NULL, @create_user, @create_time ),
( '小时任务4', @task_type_id, '不串行，最后一个周期依赖小时任务', 'hour', NULL, @not_serial, NOW()-INTERVAL 3 HOUR, NULL, @create_user, @create_time ),
( '5分钟任务', @task_type_id, '5分钟任务', 'interval', '10', @not_serial, NOW()-INTERVAL 1 HOUR, NULL, @create_user, @create_time ),
( '30分钟任务', @task_type_id, '30分钟任务', 'interval', '30', @not_serial, NOW()-INTERVAL 1 HOUR, NULL, @create_user, @create_time ),
( '终极任务1', @task_type_id, '23:59:59执行', 'day', NULL, @not_serial, CONCAT(CURDATE()-INTERVAL 1 DAY,' ',@the_time), NULL, @create_user, @create_time ),
( '终极任务2', @task_type_id, '23:59:59执行', 'week', @week_num, @not_serial, CONCAT(CURDATE()-INTERVAL 1 WEEK,' ',@the_time), NULL, @create_user, @create_time ),
( '终极任务3', @task_type_id, '23:59:59执行', 'month', DATE_FORMAT(NOW(),	'%d'), @not_serial, CONCAT(CURDATE()-INTERVAL 1 MONTH,' ',@the_time), NULL, @create_user, @create_time ),
( '终极任务4', @task_type_id, '23:59:59执行', 'hour', NULL, @not_serial, CONCAT(CURDATE()-INTERVAL 1 DAY,' ',@the_time), NULL, @create_user, @create_time ),
( '终极任务5', @task_type_id, '23:59:59执行', 'interval', '30', @not_serial, CONCAT(CURDATE()-INTERVAL 1 DAY,' ',@the_time), NULL, @create_user, @create_time );

INSERT INTO t_task_link ( task_id, task_pid, link_type, create_user, create_time ) VALUES 
( 3, 1, 0, @create_user, @create_time ),
( 4, 1, 1, @create_user, @create_time ),
( 7, 1, 0, @create_user, @create_time ),
( 8, 1, 1, @create_user, @create_time ),
( 9, 5, 0, @create_user, @create_time ),
( 10, 5, 1, @create_user, @create_time ),
( 13, 1, 0, @create_user, @create_time ),
( 14, 1, 1, @create_user, @create_time ),
( 15, 11, 0, @create_user, @create_time ),
( 16, 11, 1, @create_user, @create_time ),
( 19, 17, 0, @create_user, @create_time ),
( 20, 17, 1, @create_user, @create_time );
