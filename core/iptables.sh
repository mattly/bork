action=$1
shift

case $action in
  status)
    out=$(bake sudo iptables -C $* 2>&1)
    status=$?
    [ "$status" -gt 0 ] && return $STATUS_MISSING
    return $STATUS_OK ;;
  install)
    bake sudo iptables -A $*
    ;;
  *) return 1 ;;
esac
