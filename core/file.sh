action=$1
targetfile=$2
sourcefile=$3
shift 3
perms=$(arguments get permissions $*)
user=$(arguments get user $*)

case $action in
  status)
    bake [ -f $targetfile ] || return 10
    if [ ! -f $sourcefile ]; then
      echo "source file doesn't exist: $sourcefile"
      return 40
    fi
    sourcesum=$(eval $(md5cmd $platform $sourcefile))
    targetsum=$(bake $(md5cmd $platform $targetfile))
    if [ "$targetsum" != $sourcesum ]; then
      echo "expected sum: $sourcesum"
      echo "received sum: $targetsum"
      return 20
    fi
    if [ -n "$perms" ]; then
      existing_perms=$(bake $(permission_cmd $platform) $targetfile)
      if [ "$existing_perms" != $perms ]; then
        echo "expected permissions: $perms"
        echo "received permissions: $existing_perms"
        return 11
      fi
    fi
    return 0
    ;;
  install|upgrade)
    bake mkdir -p $(dirname $targetfile)
    bake cp $sourcefile $targetfile
    [ -n "$perms" ] && bake chmod $perms $targetfile
    return 0
    ;;
  *) return 1 ;;
esac
