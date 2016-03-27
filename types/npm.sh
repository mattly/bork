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

    list=$(bake npm ls -g --depth 0)
    str_matches "$list" " $pkgname@" || return $STATUS_MISSING

    outdated=$(bake npm outdated -g)
    # TODO further tests against version for pinned versions, git urls, etc
    str_matches "$outdated" "^$pkgname " && return $STATUS_OUTDATED

    return $STATUS_OK
    ;;

  install)
    bake npm -g install "$pkgname"
    ;;

  upgrade)
    bake npm -g update "$pkgname"
    ;;

  *) return 1 ;;
esac
