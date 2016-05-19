# dict types should be specified as such:
# ok defaults com.runningwithcrayons.Alfred-Preferences hotkey.default dict key -int 49 mod -int 1048576 string Space
# TODO maybe have multi-stage dict key/value declarations using dict-add as such:
# ok defaults com.runningwithcrayons.Alfred-Preferences hotkey.default dict
# ok defaults com.runningwithcrayons.Alfred-Preferences hotkey.default dict-entry key -int 49
# ok defaults com.runningwithcrayons.Alfred-Preferences hotkey.default dict-entry mod -int 1048576
# ok defaults com.runningwithcrayons.Alfred-Preferences hotkey.default dict-entry string Space

# TODO handle array values
# TODO recognize when domain is path to /Library/Preferences and prefix bake cmd with sudo

action=$1
domain=$2
key=$3
desired_type=$4

[ "$desired_type" = "int" ] && desired_type="integer"

shift 4

if [ "${desired_type:0:4}" = "dict" ]; then
  desired_val=$*
else
  desired_val=$1
fi

case $action in
  desc)
    echo "asserts settings for OS X's 'defaults' system"
    echo "* defaults domain key type value"
    echo "> defaults com.apple.dock autohide bool true"
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
    if [ "$current_type" = "dictionary" ]; then
      current_type="dict"
      bag init temp_defaults_value
      bag push temp_defaults_value "{"
      while [ -n "$1" ]; do
        key=$1
        shift
        next="$1"
        [ ${next:0:1} = '-' ] && shift
        value=$1
        shift
        bash push temp_defaults_value "  $key = $value"
      done
      bag push temp_defaults_value "}"
      desired_val=$(bag print temp_defaults_value)
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
    return $STATUS_OK
    ;;

  install|upgrade)
    bake defaults write $domain $key "-$desired_type" $desired_val
    ;;

  *) return 1 ;;
esac
