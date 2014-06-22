# TODO
# - check --shell argument for existence of shell, presence in /etc/shells
# - need to check --groups to make sure they exist
# - ability to check group memberships on Darwin?
# - no useradd binary on Darwin

action=$1
handle=$2
shift 2

shell=$(arguments get shell $*)
groups=$(arguments get groups $*)

user_get () {
  row=$(bake cat /etc/passwd | grep -E "^$1:")
  stat=$?
  echo $row
  return $stat
}

user_shell () {
  current_shell=$(echo "$1" | cut -d: -f 7)
  if [ "$current_shell" != $2 ]; then
    echo $current_shell
    return 1
  fi
  return 0
}

user_groups () {
  current_groups=$(bake groups $1)
  case $platform in
    Linux) current_groups=$(echo "$current" | cut -d: -f 2) ;;
  esac
  missing_groups=
  expected_groups=$(IFS=','; echo $2)

  for group in $expected_groups; do
    echo "$current_groups" | grep -E "\b$group\b" > /dev/null
    if [ "$?" -gt 0 ]; then
      missing_groups=1
      echo $group
    fi
  done

  [ -n "$missing_groups" ] && return 1
  return 0
}

case $action in
  status)
    needs_exec "useradd" || return $STATUS_FAILED_PRECONDITION

    row=$(user_get $handle)
    [ "$?" -gt 0 ] && return $STATUS_MISSING

    if [ -n "$shell" ]; then
      msg=$(user_shell "$row" $shell)
      if [ "$?" -gt 0 ]; then
        echo "--shell: expected $shell; is $msg"
        mismatched=1
      fi
    fi

    if [ -n "$groups" ]; then
      msg=$(user_groups $handle $groups)
      if [ "$?" -gt 0 ]; then
        echo "--groups: expected $groups; missing $(echo $msg)"
        partial=1
      fi
    fi
    [ -n "$mismatched" ] && return $STATUS_MISMATCH_UPGRADE
    [ -n "$partial" ] && return $STATUS_PARTIAL
    return 0 ;;

  install)
    args="-m"
    [ -n "$shell" ] && args="$args --shell $shell"
    [ -n "$groups" ] && args="$args --groups $groups"
    bake useradd $args $handle
    ;;

  upgrade)
    if ! user_shell $(user_get $handle) $shell ; then
      bake chsh -s $shell $handle
    fi
    missing=$(user_groups $handle $groups)
    if [ "$?" -gt 0 ]; then
      groups_to_create=$(IFS=','; echo $missing)
      for group in $groups_to_create; do
        bake adduser $handle $group
      done
    fi
    ;;

  *) return 1 ;;
esac
