brew_cmd="command brew"
if [ -n "$command_brew" ]; then brew_cmd=$command_brew; fi

action=$1
name=$2
shift 2

if [ -z "$name" ]; then
  case $action in
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
else
  case $action in
    depends) echo "pkg: brew" ;;
    status)
      $(str_contains "$($brew_cmd list)" "$name")
      [ "$?" -gt 0 ] && return 10
      $(str_contains "$($brew_cmd outdated | awk '{print $1}')" "$name")
      [ "$?" -eq 0 ] && return 11
      return 0 ;;
    install) bake "$brew_cmd install $name" ;;
    upgrade) bake "$brew_cmd upgrade $name" ;;
    *) return 1 ;;
  esac
fi

# from old version, keeping it around until all functionality merged in
# brew_taps=$(command brew tap)

# brew_tap () {
#   if ! contains "$brew_taps" $1 ; then
#     bake "command brew tap $1"
#   fi
# }

