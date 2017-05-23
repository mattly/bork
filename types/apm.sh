# TODO tests - because it ain't code without tests
# TODO --version - support for status, install, update

action=$1
pkgname=$2
shift 2

if hash "apm" 2>/dev/null; then
  bin="apm"
elif hash "apm-beta" 2>/dev/null; then
  bin="apm-beta"
fi

case $action in
  desc)
    echo "asserts the presence of an atom package"
    echo "> apm docblockr"
    ;;
  status)
    needs_exec "${bin}" || return $STATUS_FAILED_PRECONDITION
    pkgs=$(bake ${bin} ls --installed -b| # list all installed packages
      sed 's/@[0-9\.]*//g')       # remove version pattern (@0.1.6)
    if ! str_matches "$pkgs" "^$pkgname$"; then
      return $STATUS_MISSING
    fi
    return 0
    ;;
  install)
    bake ${bin} install "$pkgname"
    ;;
esac
