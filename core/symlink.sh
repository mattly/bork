action=$1
shift

dest=
tmpl='$f'

while [ ${1:0:2} = '--' ]; do
  pair=${1:2}   # strip off leading --
  key=${pair%%=*}  # everything before =
  val=${pair##*=}  # everything after =
  case $key in
    dest) dest=$val ;;
    tmpl) tmpl=$val ;;
    *)    return 1 ;;
  esac
  shift
done

bork_symlink_name_for_file () {
  f=$(basename $1)
  fname=$(eval echo "$2")
  if [ -n "$dest" ]; then echo $dest/$fname
  else echo $fname
  fi
}

case "$action" in
  status)
    # TODO: conflicts accumulator, list all conflicts
    missing=0
    accum=0
    for item in $*; do
      (( accum++ ))
      fname=$(bork_symlink_name_for_file $item $tmpl)
      if bake [ -h $fname ]; then
        if [ "$(bake readlink $fname)" != $item ]; then
          echo "$fname points to wrong destination"
          return 20
        else
          : # is current
        fi
      elif bake [ -e $fname ]; then
        echo "$fname exists as a non-symlink"
        return 20
      else
        (( missing++ ))
      fi
    done
    [ "$missing" -eq $accum ] && return $STATUS_MISSING
    [ "$missing" -gt 0 ] && return $STATUS_PARTIAL
    return $STATUS_OK
    ;;
  install|upgrade)
    for file in $*; do
      fname=$(bork_symlink_name_for_file $file $tmpl)
      bake [ ! -h $fname ] && bake "ln -s $file $fname"
    done
    return 0
    ;;
  *) return 1;;
esac
