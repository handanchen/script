# 任务配置状态
readonly TASK_STATUS_NORMAL=0        # 正常

# 任务实例状态
readonly TASK_STATE_INITIAL=0        # 初始状态
readonly TASK_STATE_READY=1          # 就绪
readonly TASK_STATE_RUNNING=2        # 正在运行
readonly TASK_STATE_SUCCESS=6        # 运行成功
readonly TASK_STATE_FAILED=9         # 运行失败

# 业务表类型
readonly TABLE_TYPE_SIMPLE=0         # 单表
readonly TABLE_TYPE_SHARDING=1       # 分表
readonly TABLE_TYPE_DYNAMIC=2        # 动态表

# 元数据库配置
META_DB_TYPE=$DB_TYPE_MYSQL
META_DB_HOST=192.168.1.102
META_DB_PORT=3306
META_DB_USER=etl
META_DB_PASSWD=123456
META_DB_NAME=schedule
META_DB_URL=$(make_mysql_url $META_DB_HOST $META_DB_USER $META_DB_PASSWD $META_DB_NAME $META_DB_PORT)
META_DB_CHARSET=utf8

# 开关
META_SQL_LOG=$SWITCH_ON     # sql日志开关，默认“开启”

# 文件目录
META_SQL_LOG_PATH=${SQL_LOG_PATH}       # sql日志文件路径
TASK_LOG_PATH=${LOG_PATH}/task          # 任务日志目录
TASK_TMP_PATH=${TMP_PATH}/task          # 任务临时文件目录
TASK_DATA_PATH=${DATA_PATH}/task        # 任务数据文件目录

# 异常编码
E_UNSUPPORTED_TASK_CYCLE=10000          # 不支持的任务周期类型
E_UNSUPPORTED_DEPS_TYPE=10001           # 不支持的依赖类型
E_UNSUPPORTED_TABLE_TYPE=10002          # 不支持的表类型
