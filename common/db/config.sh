# ���ݿ�������Ϣ


# ���ݿ�����
readonly DB_TYPE_MYSQL=mysql
readonly DB_TYPE_ORACLE=oracle
readonly DB_TYPE_POSTGRES=postgresql
readonly DB_TYPE_MSSQL=mssqlserver
readonly DB_TYPE_SYBASE=sybase

# ����ͬ��ָ��
readonly CMD_CREATE_TABLE=table             # ������
readonly CMD_CREATE_EXP=table_file          # �����������ļ�
readonly CMD_CREATE_IMP=table_file_data     # ��������������
readonly CMD_EXP_FILE=file                  # �����ļ�
readonly CMD_IMP_DATA=file_data             # ��������

# ������ָ��
readonly CMD_CREATE_SKIP=skip         # ����
readonly CMD_CREATE_AUTO=auto         # ����
readonly CMD_CREATE_DROP=drop         # ��ɾ���󴴽�

# ����װ��ģʽ
readonly LOAD_MODE_IGNORE=ignore          # �����ظ�����
readonly LOAD_MODE_APPEND=append          # ׷��
readonly LOAD_MODE_REPLACE=replace        # �滻�ظ�����
readonly LOAD_MODE_TRUNCATE=truncate      # �������

# ����
SQL_LOG=$SWITCH_ON              # sql��־���أ�Ĭ�ϡ�������

# �ļ�Ŀ¼
SQL_LOG_PATH=${LOG_PATH}/sql    # sql��־Ŀ¼

# �쳣����
E_UNSUPPORTED_DB=2000       # ��֧�ֵ����ݿ�
