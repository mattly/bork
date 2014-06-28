# TODO
# - what's the use case for the --dest argument, again?  Most other types don't work that way.
# - can we shift that first while loop down there to the `arguments` helper?

action=$1
shift

dest=
tmpl='$f'

if [ -n "$1" ]; then
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
fi

bork_symlink_name_for_file () {
  f=$(basename $1)
  fname=$(eval echo "$2")
  if [ -n "$dest" ]; then echo $dest/$fname
  else echo $fname
  fi
}

case "$action" in
  desc)
    echo "assert presence and target of symlinks"
    echo "* symlinks [options] ~/code/dotfiles/configs/*"
    echo "--tmpl='.\$f'"
    ;;
  status)
    missing=0
    accum=0
    conflict=
    for item in $*; do
      (( accum++ ))
      fname=$(bork_symlink_name_for_file $item $tmpl)
      if bake [ -h $fname ]; then
        if [ "$(bake readlink $fname)" != $item ]; then
          echo "incorrect target for existing symlink: $fname"
          conflict=1
        fi
      elif bake [ -e $fname ]; then
        echo "not a symlink: $fname"
        conflict=1
      else
        (( missing++ ))
      fi
    done

    [ -n "$conflict" ] && return $STATUS_CONFLICT_UPGRADE
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
