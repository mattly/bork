# TODO
# - cache output of apt-get update, only needs to be done once per run
# - perhaps move the apt-get update command out to a separate call without
#   a package name, similar to how the "brew" type does it.
# - specify versions to install with --version flag (ie, ruby=2.0.0)
# - specify distribution to install from with --dist flag (ie ruby/unstable)

action=$1
name=$2
shift 2
case $action in
  status)
    baking_platform_is "Linux" || return $STATUS_UNSUPPORTED_PLATFORM
    needs_exec "apt-get" 0
    needs_exec "dpkg" $?
    [ "$?" -gt 0 ] && return $STATUS_FAILED_PRECONDITION

    echo "$(bake dpkg --get-selections)" | grep -E "^$name\\s+install$"
    [ "$?" -gt 0 ] && return $STATUS_MISSING

    outdated=$(bake sudo apt-get -u update --dry-run \
                | grep "^Inst" | awk '{print $2}')
    $(str_contains "$outdated" "$name")
    [ "$?" -eq 0 ] && return $STATUS_OUTDATED
    return $STATUS_OK
    ;;

  install|upgrade)
    bake sudo apt-get --yes install $name
    ;;

  *) return 1 ;;
esac

