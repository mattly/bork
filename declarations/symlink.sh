action=$1
glob=$2
shift 2

dest=$(arguments get dest $*)

tmpl='$f'
targ=$(arguments get tmpl $*)
[ -n "$targ" ] && tmpl="$targ"

bork_symlink_name_for_file () {
  f=$(basename $1)
  fname=$(eval echo "$tmpl")
  if [ -n "$dest" ]; then echo $dest/$fname
  else echo $fname
  fi
}

case "$action" in
  status)
    missing=0
    accum=0
    for item in $glob; do
      (( accum++ ))
      fname=$(bork_symlink_name_for_file $item)
      if [ -h $fname ]; then
        if [ "$(readlink $fname)" != $item ]; then
          echo "$fname points to wrong destination"
          return 20
        else
          : # is current
        fi
      elif [ -e $fname ]; then
        echo "$fname exists as a non-symlink"
        return 20
      else
        (( missing++ ))
      fi
    done
    [ "$missing" -eq $accum ] && return 10
    [ "$missing" -gt 0 ] && return 11
    return 0
    ;;
  install|upgrade)
    for f in $glob; do
      fname=$(bork_symlink_name_for_file $f)
      [ ! -h $fname ] && bake "ln -s $f $fname"
    done
    return 0
    ;;
  *) return 1;;
esac
