action=$1
groupname=$2
shift 2

case $action in
  status)
    bake cat /etc/group | grep -E "^$groupname:"
    [ "$?" -gt 0 ] && return 10
    return 0;;
  install)
    bake groupadd $groupname ;;
  *) return 1 ;;
esac
