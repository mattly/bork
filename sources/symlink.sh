action=$1
pattern=$2
shift 2

case $action in
  status)
    missing=0
    accum=0
    for f in $pattern; do
      (( accum++ ))
      fname=$(basename $f)
      if [ -e $fname ]; then
        [ ! -L $fname ] && return 20
        [ "$(readlink $fname)" != $f ] && return 20
      else
        (( missing++ ))
      fi
    done
    [ "$missing" -eq $accum ] && return 10
    [ "$missing" -gt 0 ] && return 11
    return 0
    ;;
  *) return 1;;
esac
