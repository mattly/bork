# TODO tests on check type

action=$1
shift 1
case $action in
  desc)
    echo "runs a given command.  OK if returns 0, FAILED otherwise."
    echo '* check evalstr'
    echo '> check "[ -d $HOME/.ssh/id_rsa ]"'
    echo '> if check_failed; then ...'
    ;;
  status)
    eval "$*"
    [ "$?" -gt 0 ] && return $STATUS_FAILED || return $STATUS_OK
    ;;
esac
