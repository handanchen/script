# 数据库配置信息


# 数据库类型
readonly DB_TYPE_MYSQL=mysql
readonly DB_TYPE_ORACLE=oracle
readonly DB_TYPE_POSTGRES=postgresql
readonly DB_TYPE_MSSQL=mssqlserver
readonly DB_TYPE_SYBASE=sybase

# 数据同步指令
readonly CMD_CREATE_TABLE=table             # 创建表
readonly CMD_CREATE_EXP=table_file          # 创建表、导出文件
readonly CMD_CREATE_IMP=table_file_data     # 创建表、导入数据
readonly CMD_EXP_FILE=file                  # 导出文件
readonly CMD_IMP_DATA=file_data             # 导入数据

# 创建表指令
readonly CMD_CREATE_SKIP=skip         # 跳过
readonly CMD_CREATE_AUTO=auto         # 创建
readonly CMD_CREATE_DROP=drop         # 先删除后创建

# 数据装载模式
readonly LOAD_MODE_IGNORE=ignore          # 忽略重复数据
readonly LOAD_MODE_APPEND=append          # 追加
readonly LOAD_MODE_REPLACE=replace        # 替换重复数据
readonly LOAD_MODE_TRUNCATE=truncate      # 清空数据

# 开关
SQL_LOG=$SWITCH_ON              # sql日志开关，默认“开启”

# 文件目录
SQL_LOG_PATH=${LOG_PATH}/sql    # sql日志目录

# 异常编码
E_UNSUPPORTED_DB=2000       # 不支持的数据库
