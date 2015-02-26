#!/bin/bash
#
# 守护进程
# 用法:
: '
BASE_DIR=/script
*/5 * * * * $BASE_DIR/daemon.sh /script/schedule/task_manager.sh stay >> $BASE_DIR/log/task_manager.log 2>&1
*/5 * * * * $BASE_DIR/daemon.sh /script/schedule/task_scheduler.sh stay >> $BASE_DIR/log/task_scheduler.log 2>&1
'


command="$1"
shift
params="$@"

cur_time=`date +'%F %T'`

if [[ -n "$command" ]]; then
    self_name=`basename $0`
    thread_count=`ps -ef | grep "$command" | grep -Ev "$self_name|grep" | wc -l`
    if [[ $thread_count -eq 0 ]]; then
        echo "$cur_time INFO [ Start command: $command $params ]"
        exec $command $params
    else
        echo "$cur_time DEBUG [ The command: $command is already running ]"
    fi
else
    echo "$cur_time ERROR [ There is nothing to be started ]" >&2
fi
