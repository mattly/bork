cmd="command brew"

case $1 in
  depends)
    echo "platform: Darwin"
    echo "exec: ruby"
    ;;
  status)
    has_exec "brew"
    [ "$?" -gt 0 ] && return 10
    changes=$(cd /usr/local; git fetch --quiet; git log master..origin/master)
    [ "$(echo $changes | wc -l | awk '{print $1}')" -gt 0 ] && return 11
    ;;
  # install)
    # bake --eval 'ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"'
    # ;;
  upgrade)
    bake "$cmd update"
    ;;
  *) return 1 ;;
esac
