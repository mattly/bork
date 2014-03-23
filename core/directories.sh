action=$1
shift

case "$action" in
  status)
    missing=0
    accum=0
    for dir in $*; do
      (( accum++ ))
      if [ ! -d $dir ]; then
        [ -e $dir ] && return 20
        (( missing++ ))
      fi
    done
    [ "$missing" -eq $accum ] && return 10
    [ "$missing" -gt 0 ] && return 11
    return 0
    ;;
  install|upgrade)
    for dir in $*; do
      [ ! -d $dir ] && bake "mkdir -p $dir"
    done
    ;;
  *) return 1 ;;
esac

