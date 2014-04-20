action=$1
groupname=$2
shift 2

group_list () {
  if [ -n "$group_list_cmd" ]; then $group_list_cmd
  else echo "$(cat /etc/group)"
  fi
}

case $action in
  status)
    group_list | grep -E "^$groupname:"
    [ "$?" -gt 0 ] && return 10
    return 0;;
  install)
    bake "groupadd $groupname" ;;
  *) return 1 ;;
esac
