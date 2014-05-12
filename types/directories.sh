# TODO
# - add --permissions flag, perhaps copy/extract from file?

action=$1
shift

case "$action" in
  status)
    missing=0
    accum=0
    conflict=
    for dir in $*; do
      (( accum++ ))
      if bake [ ! -d $dir ]; then
        if bake [ -e $dir ]; then
          echo "target exists as non-directory: $dir"
          conflict=1
        else (( missing++ ))
        fi
      fi
    done

    [ -n "$conflict" ] && return $STATUS_CONFLICT_UPGRADE
    [ "$missing" -eq $accum ] && return $STATUS_MISSING
    [ "$missing" -gt 0 ] && return $STATUS_PARTIAL
    return $STATUS_OK
    ;;

  install|upgrade)
    for dir in $*; do
      bake [ ! -d $dir ] && bake mkdir -p $dir
    done
    ;;

  *) return 1 ;;
esac

