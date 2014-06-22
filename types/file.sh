# TODO
# - change compiled filename transformation to md5 representation instead of base64
# - any way to test for sudo???
# - distinguish target from local system for file sums

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

case $action in
  status)
    if ! is_compiled && [ ! -f $sourcefile ]; then
      echo "source file doesn't exist: $sourcefile"
      return $STATUS_FAILED_ARGUMENTS
    fi
    if [ -n "$owner" ]; then
      owner_id=$(bake id -u $owner)
      if [ "$?" -gt 0 ]; then
        echo "unknown owner: $owner"
        return $STATUS_FAILED_ARGUMENT_PRECONDITION
      fi
    fi

    bake [ -f $targetfile ] || return $STATUS_MISSING

    # TODO: need to distinguish local platfrom from target platform
    if is_compiled; then
      md5c=$(md5cmd $platform)
      sourcesum=$(echo "${!file_varname}" | base64 --decode | eval $md5c)
    else
      sourcesum=$(eval $(md5cmd $platform $sourcefile))
    fi
    targetsum=$(_bake $(md5cmd $platform $targetfile))
    if [ "$targetsum" != $sourcesum ]; then
      echo "expected sum: $sourcesum"
      echo "received sum: $targetsum"
      return $STATUS_CONFLICT_UPGRADE
    fi

    mismatch=
    if [ -n "$perms" ]; then
      existing_perms=$(_bake $(permission_cmd $platform) $targetfile)
      if [ "$existing_perms" != $perms ]; then
        echo "expected permissions: $perms"
        echo "received permissions: $existing_perms"
        mismatch=1
      fi
    fi
    if [ -n "$owner" ]; then
      existing_user=$(_bake ls -l $targetfile | awk '{print $3}')
      if [ "$existing_user" != $owner ]; then
        echo "expected owner: $owner"
        echo "received owner: $existing_user"
        mismatch=1
      fi
    fi
    [ -n "$mismatch" ] && return $STATUS_MISMATCH_UPGRADE
    return 0
    ;;

  install|upgrade)
    dirn=$(dirname $targetfile)
    [ "$dirn" != . ] && _bake mkdir -p $dirn
    [ -n "$owner" ] && _bake chown $owner $dirn
    if is_compiled; then
      _bake "echo \"${!file_varname}\" | base64 --decode > $targetfile"
    else
      _bake cp $sourcefile $targetfile
    fi
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
