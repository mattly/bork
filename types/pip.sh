# TODO --sudo flag
# TODO versions
# TODO update

action=$1
name=$2
shift 2

case $action in
  desc)
    echo "asserts presence of packages installed via pip"
    echo "> pip pygments"
    ;;
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

