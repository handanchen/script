# 定时器


# 执行操作
function execute()
{
    while [[ -z "$timeout" || $timeout -gt 0 ]]; do
      $cmd
      if [ -n "$timeout" ]; then
        timeout=$((timeout - interval))
      fi
      sleep ${interval}m
    done
}

function main()
{
    # 要执行的命令
    cmd="$1"
    # 执行频率（单位为分钟）
    interval="$2"
    # 多久超时（单位为分钟）
    timeout="$3"

    execute
}

main "$@"
