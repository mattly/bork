action=$1
domain=$2
key=$3
desired_type=$4
desired_val=$5

case $action in
  desc)
    echo "asserts settings for OS X's 'defaults' system"
    echo "> defaults domain key type value"
    echo "* defaults com.apple.dock autohide bool true"
    ;;
  status)
    needs_exec "defaults" || return $STATUS_FAILED_PRECONDITION
    current_val=$(bake defaults read $domain $key)
    [ "$?" -eq 1 ] && return $STATUS_MISSING

    current_type=$(str_get_field "$(bake defaults read-type $domain $key)" 3)
    conflict=

    if [ "$current_type" = "boolean" ]; then
      current_type="bool"
      case "$current_val" in
        0) current_val="false" ;;
        1|YES) current_val="true" ;;
      esac
    fi
    if [ "$desired_type" != $current_type ]; then
      conflict=1
      echo "expected type: $desired_type"
      echo "received type: $current_type"
    fi
    if [ "$current_val" != $desired_val ]; then
      conflict=1
      echo "expected value: $desired_val"
      echo "received value: $current_val"
    fi
    [ -n "$conflict" ] && return $STATUS_MISMATCH_UPGRADE
    return 0 ;;
  install|upgrade)
    bake defaults write $domain $key "-$desired_type" $desired_val
    ;;
  *) return 1 ;;
esac
