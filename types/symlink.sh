action=$1
source=$2
shift 2

if [ -n "$source" ]; then
  tmpl='$f'
  given_tmpl=$(arguments get tmpl $*)
  [ -n "$given_tmpl" ] && tmpl=$given_tmpl

  f=$(basename $source)
  target=$(echo $(eval echo "$tmpl"))
fi

case "$action" in
  desc)
    echo "assert presence and target of a symlink"
    echo "* symlink ~/code/dotfiles/configs/vimrc --tmpl='.\$f'"
    echo "--tmpl='.\$f'"
    ;;
  status)
    if bake [ -h $target ]; then
      existing_source=$(bake readlink $target)
      if [ "$existing_source" != $source ]; then
        echo "received source for existing symlink: $existing_source"
        echo "expected source for symlink: $source"
        return $STATUS_MISMATCH_CLOBBER
      else
        return $STATUS_OK
      fi
    elif bake [ -e $target ]; then
      echo "not a symlink: $target"
      return $STATUS_CONFLICT_CLOBBER
    else
      return $STATUS_MISSING
    fi ;;

  install|upgrade)
    bake ln -s $source $target ;;

  *) return 1;;
esac
