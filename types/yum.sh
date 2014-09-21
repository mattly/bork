
action=$1
name=$2
shift 2
case $action in
  desc)
    echo "asserts packages installed via yum on CentOS or RedHat"
    echo "* yum package-name"
    ;;
  status)
    baking_platform_is "Linux" || return $STATUS_UNSUPPORTED_PLATFORM
    needs_exec "yum" 0
    [ "$?" -gt 0 ] && return $STATUS_FAILED_PRECONDITION

    echo "$(bake rpm -qa)" | grep "^$name"
    [ "$?" -gt 0 ] && return $STATUS_MISSING

    echo "$(bake sudo yum list updates)" | grep "^$name"
    [ "$?" -eq 0 ] && return $STATUS_OUTDATED
    return $STATUS_OK
    ;;

  install|upgrade)
    bake sudo yum -y install $name
    ;;

  *) return 1 ;;
esac
