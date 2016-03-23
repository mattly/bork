# TODO add --permissions flag, perhaps copy/extract from file?

action=$1
dir=$2
shift 2

case "$action" in
  desc)
    echo "asserts presence of a directory"
    echo "* directories ~/.ssh"
    ;;

  status)
    [ ! -e "$dir" ] && return $STATUS_MISSING
    [ -d "$dir" ] && return $STATUS_OK
    echo "target exists as non-directory"
    return $STATUS_CONFLICT_CLOBBER
    ;;

  install) bake mkdir -p $dir ;;

  *) return 1 ;;
esac
