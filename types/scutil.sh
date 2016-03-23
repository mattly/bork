# TODO tests

action=$1
type=$2
name=$3
shift 3

case $action in
  desc)
    echo "Verifies OS X machine name with scutil"
    echo "> scutil ComputerName bork"
    ;;
  status)
    needs_exec "scutil" || return $STATUS_FAILED_PRECONDITION
    current_val=$(bake scutil --get $type)
    if [ "$current_val" != $name ]; then
      echo "expected: $name"
      echo "received: $current_val"
      return $STATUS_MISMATCH_UPGRADE
    fi
    return $STATUS_OK
    ;;
  upgrade)
    bake scutil --set $type $name
    ;;
esac
