# TODO doesn't work on Darwin, is groupadd a GNU thing?

action=$1
groupname=$2
shift 2

case $action in
  desc)
    echo "asserts presence of a unix group (linux only, for now)"
    echo "> group admin"
    ;;
  status)
    needs_exec groupadd || return $STATUS_FAILED_PRECONDITION

    bake cat /etc/group | grep -E "^$groupname:"
    [ "$?" -gt 0 ] && return $STATUS_MISSING
    return $STATUS_OK ;;

  install)
    bake groupadd $groupname ;;

  *) return 1 ;;
esac
