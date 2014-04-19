action=$1
handle=$2
shift 2

shell=$(arguments get shell $*)

users_list () {
  if [ -n "$user_list_cmd" ]; then $user_list_cmd
  else echo "$(cat /etc/password)"
  fi
}

user_get () {
  row=$(users_list | grep -E "^$1:")
  stat=$?
  echo $row
  return $stat
}
user_shell () {
  current_shell=$(echo "$1" | cut -d: -f 7)
  if [ "$current_shell" != $2 ]; then
    echo "--shell: expected $shell, was $current_shell"
    return 1
  fi
  return 0
}

case $action in
  status)
    row=$(user_get $handle)
    [ "$?" -gt 0 ] && return 10
    if [ -n "$shell" ]; then
      msg=$(user_shell "$row" $shell)
      if [ "$?" -gt 0 ]; then
        echo "$msg"
        return 11
      fi
    fi
    return 0 ;;
  install)
    args="-m"
    [ -n "$shell" ] && args="$args --shell $shell"
    bake "useradd $args $handle"
    ;;
  upgrade)
    if ! user_shell $(user_get $handle) $shell ; then
      bake "chsh -s $shell $handle"
    fi
    ;;
  *) return 1 ;;
esac
