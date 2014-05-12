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
