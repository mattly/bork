case bork_mode in
  depends)
    echo "platform: Darwin"
    echo "exec: ruby"
    ;;
  status)
    has_exec "brew"
    [ "$?" -eq 0 ] && return 0 || return 10
    ;;
  # satisfy)
    # bake --eval 'ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"'
    # ;;
esac
