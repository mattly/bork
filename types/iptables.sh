# TODO
# - test for precondition of iptables exec
# - need a way to test for ordering of rules, discussion in the original PR: https://github.com/mattly/bork/pull/10
# - maybe take the chain as the first argument, the rule as the rest?

action=$1
shift

case $action in
  desc)
    echo "asserts presence of iptables rule"
    echo "NOTE: does not assert ordering of rules"
    echo "> iptables INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT"
    ;;
  status)
    out=$(bake sudo iptables -C $* 2>&1)
    status=$?
    [ "$status" -gt 0 ] && return $STATUS_MISSING
    return $STATUS_OK ;;

  install)
    bake sudo iptables -A $*
    ;;

  *) return 1 ;;
esac
