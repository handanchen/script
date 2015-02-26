# hive工具


# 特殊字符转义
# (' ;)
function hive_escape()
{
    sed "s/\('\|;\)/\\\\\1/g"
}
