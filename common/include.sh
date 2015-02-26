# 常用工具


source $SHELL_HOME/common/config.sh


# 生成等长数字序列
# 参数:
#   最小数字
#   最大数字
#   跨度（可选）
# 示例:
#   range_num 0 99
#   range_num 0 98 2
function range_num()
{
    echo $@ | awk '{
        num_begin=$1
        num_end=$2
        span=$3 > 0 ? $3 : 1

        size=length(num_end)

        while(num_begin <= num_end){
            printf("%0*d\n",size,num_begin)
            num_begin += span
        }
    }'
}

# 生成等长随机字数字
# 参数:
#   位数（可选）
#   个数（可选）
function random_num()
{
    echo $@ | awk 'BEGIN{
        srand()
    }{
        digit=$1 > 0 ? $1 : 1
        num=$2 > 0 ? $2 : 1
        for(i=0;i < num;i++){
            value=10 ^ digit * rand()
            printf("%0*d\n",digit,value)
        }
    }'
}

# 去掉左右空格
function trim()
{
    sed 's/^[[:space:]]*\|[[:space:]]*$//g'
}

# 转小写
function to_lower()
{
    tr 'A-Z' 'a-z'
}

# 转大写
function to_upper()
{
    tr 'a-z' 'A-Z'
}

# 左对齐
# 参数:
#   原字符串
#   补位后的长度
#   填充字符（可选，如果原字符串是数字，则默认为0）
function lalign()
{
    echo $@ | awk '{
        value=$1
        total_size=$2
        char=$3 > "" ? $3 : " "

        if(value ~ /^[[:digit:]]*$/) char=char > " " ? char : 0

        size=total_size - length(value)

        printf("%s",value)
        for(i=1;i<size;i++){
            printf("%s",char)
        }
        printf("%s\n",char)
    }'
}

# 获取文件大小
# 参数:
#   文件名
function file_size()
{
    ls -l "$1" | awk '{print $5}'
}

# 删除空目录
function delete_dir(){
    local dir="$1"

    local has=`find $dir -type d -empty | wc -l`

    if [[ $has -gt 0 ]]; then
        find $dir -type d -empty | xargs rm -rf
        delete_dir
    fi
}

# 获取本机ip
function local_ip()
{
    ifconfig eth0 2> /dev/null | grep "inet addr" | cut -d ":" -f 2 | cut -d " " -f 1
}

# 获取进程数
# 参数:
#   进程名称
#   排除列表（可选）
function count_thread()
{
    local thread="$1"
    local excludes="$2"

    if [ -z "$excludes" ]; then
        excludes="grep"
    else
        excludes="grep|$excludes"
    fi

    local count=`ps -ef | grep "$thread" | grep -Ev "$excludes" | wc -l 2> /dev/null`

    [[ -z "$count" ]] && count=0

    echo $count
}

# 记录日志
function log()
{
    echo "$(date +'%F %T') $@"
}

# 调试信息
function debug()
{
    [[ "$LOG_LEVEL" -le "$LOG_LEVEL_DEBUG" ]] && log "DEBUG [ $@ ]"
}

# 基本信息
function info()
{
    [[ "$LOG_LEVEL" -le "$LOG_LEVEL_INFO" ]] && log "INFO [ $@ ]"
}

# 警告信息
function warn()
{
    [[ "$LOG_LEVEL" -le "$LOG_LEVEL_WARN" ]] && log "WARN [ $@ ]" >&2
}

# 错误信息
function error()
{
    [[ "$LOG_LEVEL" -le "$LOG_LEVEL_ERROR" ]] && log "ERROR [ $@ ]" >&2
}

# 在方法执行前后记录日志
function log_fn()
{
    log "[$@] begin"
    $@ || return $?
    log "[$@] end"
}
