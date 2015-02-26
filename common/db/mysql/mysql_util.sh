# mysql工具


# 特殊字符转义
# (' ")
function mysql_escape()
{
    sed "s/\('\|\"\)/\\\\\1/g"
}

# 初始化数据库配置
function init_mysql_db()
{
    DEFAULT_DB_HOST=localhost
    DEFAULT_DB_PORT=3306
    DEFAULT_DB_USER=root
    DEFAULT_DB_PASSWD=123456
    DEFAULT_DB_NAME=test
    DEFAULT_DB_CHARSET=utf8
    DEFAULT_DB_OTHERS="-s -N --local-infile"
    DEFAULT_DB_URL=$(make_mysql_url)
}

# 执行sql语句
function mysql_executor()
{
    local sql="$1"
    local db_url="$2"

    if [[ -z "$sql" ]]; then
        sql=`cat`
    fi

    # 设置默认数据库连接
    if [[ -z "$db_url" ]]; then
        db_url=$DEFAULT_DB_URL
    fi

    # 记录sql日志
    if [[ "$SQL_LOG" = "$SWITCH_ON" ]]; then
        if [[ -z "$sql_log_file" ]]; then
            local sql_log_file=${SQL_LOG_PATH}/sql_$(date +%Y%m%d).log
        fi

        # 创建目录
        mkdir -p `dirname ${sql_log_file}`

        debug "$sql" >> $sql_log_file
    fi

    echo "$sql" | mysql $db_url
}

# 生成连接字符串
function make_mysql_url()
{
    local host="${1:-$DEFAULT_DB_HOST}"
    local user="${2:-$DEFAULT_DB_USER}"
    local passwd="${3:-$DEFAULT_DB_PASSWD}"
    local db="${4:-$DEFAULT_DB_NAME}"
    local port="${5:-$DEFAULT_DB_PORT}"
    local charset="${6:-$DEFAULT_DB_CHARSET}"
    local others="${7:-$DEFAULT_DB_OTHERS}"

    echo "-h $host -P $port -u $user -p$passwd -D $db --default-character-set=$charset $others"
}

init_mysql_db
