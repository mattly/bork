# TODO
# --sudo flag
# versions
# update

action=$1
name=$2
shift 2

case $action in
  status)
    needs_exec "pip" || return $STATUS_FAILED_PRECONDITION
    pkgs=$(bake pip list)
    if ! str_matches "$pkgs" "^$name"; then
      return $STATUS_MISSING
    fi
    return 0 ;;
  install)
    bake pip install "$name"
    ;;
esac

