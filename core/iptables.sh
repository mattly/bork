action=$1
shift

case $action in
  status)
    out=$(bake sudo iptables -C $* 2>&1)
    status=$?
    [ "$status" -gt 0 ] && return 10
    return 0 ;;
  *) return 1 ;;
esac
