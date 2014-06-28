action=$1
domain=$2
key=$3
desired_type=$4
desired_val=$5

case $action in
  status)
    current_type=$(str_get_field "$(defaults read-type $domain $key)" 3)
    current_val=$(defaults read $domain $key)
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
    defaults write $domain $key "-$desired_type" $desired_val
    ;;
  *) return 1 ;;
esac
