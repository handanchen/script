# 基本配置信息


# 开关
readonly SWITCH_ON=0        # 开启
readonly SWITCH_OFF=1       # 关闭

# 日志级别
readonly LOG_LEVEL_DEBUG=0      # 调试信息
readonly LOG_LEVEL_INFO=1       # 基本信息
readonly LOG_LEVEL_WARN=2       # 警告信息
readonly LOG_LEVEL_ERROR=3      # 错误信息
LOG_LEVEL=$LOG_LEVEL_DEBUG      # 设置日志级别

# 指令
readonly CMD_INIT=initialize       # 初始化
readonly CMD_STAY=stay             # 常驻内存

# 文件目录
LOG_PATH=~/log                  # 日志目录
TMP_PATH=~/tmp                  # 临时文件目录
DATA_PATH=~/data                # 数据文件目录

# 异常编码
E_INVALID_ARGS=1000         # 非法参数
