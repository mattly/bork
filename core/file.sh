action=$1
targetfile=$2
sourcefile=$3
shift 3
perms=$(arguments get permissions $*)
owner=$(arguments get owner $*)
_bake () {
  if [ -n "$owner" ]; then
    bake sudo $*
  else bake $*
  fi
}
file_varname="borkfiles__$(echo "$sourcefile" | base64 | sed -E 's|\+|_|' | sed -E 's|\?|__|' | sed -E 's|=+||')"
p "$sourcefile: $file_varname"

case $action in
  status)
    bake [ -f $targetfile ] || return 10
    if ! is_compiled && [ ! -f $sourcefile ]; then
      echo "source file doesn't exist: $sourcefile"
      return 40
    fi
    if [ -n "$owner" ]; then
      owner_id=$(bake id -u $owner)
      if [ "$?" -gt 0 ]; then
        echo "unknown owner: $owner"
        return 40
      fi
    fi
    # TODO: need to distinguish local platfrom from target platform
    if is_compiled; then
      md5c=$(md5cmd $platform)
      sourcesum=$(echo "${!file_varname}" | base64 --decode | md5)
      p $sourcesum
    else
      sourcesum=$(eval $(md5cmd $platform $sourcefile))
    fi
    targetsum=$(_bake $(md5cmd $platform $targetfile))
    p $targetsum
    if [ "$targetsum" != $sourcesum ]; then
      echo "expected sum: $sourcesum"
      echo "received sum: $targetsum"
      return 20
    fi
    outdated=
    if [ -n "$perms" ]; then
      existing_perms=$(_bake $(permission_cmd $platform) $targetfile)
      if [ "$existing_perms" != $perms ]; then
        echo "expected permissions: $perms"
        echo "received permissions: $existing_perms"
        outdated=1
      fi
    fi
    if [ -n "$owner" ]; then
      existing_user=$(_bake ls -l $targetfile | awk '{print $3}')
      if [ "$existing_user" != $owner ]; then
        echo "expected owner: $owner"
        echo "received owner: $existing_user"
        outdated=1
      fi
    fi
    [ -n "$outdated" ] && return 11
    return 0
    ;;
  install|upgrade)
    dirn=$(dirname $targetfile)
    [ "$dirn" != . ] && _bake mkdir -p $dirn
    [ -n "$owner" ] && _bake chown $owner $dirn
    _bake cp $sourcefile $targetfile
    [ -n "$owner" ] && _bake chown $owner $targetfile
    [ -n "$perms" ] && _bake chmod $perms $targetfile
    return 0
    ;;
  compile)
    echo "# source: $sourcefile"
    echo "# md5 sum: $(eval $(md5cmd $platform $sourcefile))"
    echo "$file_varname=\"$(cat $sourcefile | base64)\""
    ;;
  *) return 1 ;;
esac
