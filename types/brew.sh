# TODO:
# - write tests for the packageless 'brew' assertion
# - write install command for packageless 'brew' assertion that installs homebrew
# - something to handle brew taps? probably a separate type.

action=$1
name=$2
shift 2

if [ -z "$name" ]; then
  case $action in
    status)
      baking_platform_is "Darwin" || return $STATUS_UNSUPPORTED_PLATFORM
      needs_exec "ruby" || return $STATUS_FAILED_PRECONDITION
      has_exec "brew"
      [ "$?" -gt 0 ] && return $STATUS_MISSING
      changes=$(cd /usr/local; git fetch --quiet; git log master..origin/master)
      [ "$(echo $changes | wc -l | awk '{print $1}')" -gt 0 ] && return $STATUS_OUTDATED
      return $STATUS_OK
      ;;

    # need to make sure this actually works
    # install)
      # bake --eval 'ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"'
      # ;;

    upgrade)
      bake brew update
      ;;

    *) return 1 ;;
  esac

else
  case $action in
    status)
      baking_platform_is "Darwin" || return $STATUS_UNSUPPORTED_PLATFORM
      needs_exec "brew" || return $STATUS_FAILED_PRECONDITION

      bake brew list | grep -E "^$name$"
      [ "$?" -gt 0 ] && return $STATUS_MISSING
      bake brew outdated | awk '{print $1}' | grep -E "^$name$"
      [ "$?" -eq 0 ] && return $STATUS_OUTDATED
      return 0 ;;

    install) bake brew install $name ;;

    upgrade) bake brew upgrade $name ;;

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

