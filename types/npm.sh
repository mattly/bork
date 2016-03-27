# TODO tests - because it ain't code without tests
# TODO install - test for necessity of 'sudo' prefix
# TODO status - check version outdated status
# TODO --version - support for status, install, update

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
    pkgs=$(bake npm ls -g --parseable |
      grep "lib\/node_modules\/[-0-9A-Za-z\.-]*$")
    if ! str_matches "$pkgs" "\/$pkgname$"; then
      return $STATUS_MISSING
    fi
    return 0 ;;
  install)
    bake npm -g install "$pkgname"
    ;;
esac
