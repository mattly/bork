action=$1
gemname=$2
shift 2

case $action in
  status)
    needs_exec "gem" || return $STATUS_FAILED_PRECONDITION
    return 0 ;;
esac
