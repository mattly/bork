# TODO
# tests - because it ain't code without tests
# install - test for necessity of 'sudo' prefix
# status - check version outdated status
# --version - support for status, install, update

action=$1
pkgname=$2
shift 2

case $action in
  desc)
    echo "asserts the presence of a nodejs module in npm's global installation"
    echo "> npm grunt-cli"
    ;;
  status)
    needs_exec "npm" || return $STATUS_FAILED_PRECONDITION
    pkgs=$(bake npm ls -g --depth 0 --parseable)
    if ! str_matches "$pkgs" "\/$pkgname$"; then
      return $STATUS_MISSING
    fi
    return 0 ;;
  install)
    bake npm -g install "$pkgname"
    ;;
esac
