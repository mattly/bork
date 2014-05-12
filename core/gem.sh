# TODO
# install - test for necessity of 'sudo' prefix
# status - check against "gem outdated" list
# update - update outdated gems mentioned
# --version - support for status, install, update
# gem flags - figure out convention to pass through, similar to brew?

action=$1
gemname=$2
shift 2

case $action in
  status)
    needs_exec "gem" || return $STATUS_FAILED_PRECONDITION
    gems=$(bake gem list)
    if ! str_matches "$gems" "^$gemname"; then
      return $STATUS_MISSING
    fi
    return 0 ;;
  install)
    bake sudo gem install "$gemname"
    ;;
esac
