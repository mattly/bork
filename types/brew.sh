# TODO:
# - write tests for the packageless 'brew' assertion
# - something to handle brew taps? probably a separate type.

action=$1
name=$2
shift 2

if [ -z "$name" ]; then
  case $action in
    desc)
      echo "asserts presence of packages installed via homebrew on mac os x" 
      echo "* brew                  (installs homebrew)"
      echo "* brew package-name     (instals package)"
      ;;
    status)
      baking_platform_is "Darwin" || return $STATUS_UNSUPPORTED_PLATFORM
      needs_exec "ruby" || return $STATUS_FAILED_PRECONDITION
      path=$(bake which brew)
      [ "$?" -gt 0 ] && return $STATUS_MISSING
      changes=$(cd /usr/local; git fetch --quiet; git log master..origin/master)
      [ "$(echo $changes | sed '/^\s*$/d' | wc -l | awk '{print $1}')" -gt 0 ] && return $STATUS_OUTDATED
      return $STATUS_OK
      ;;

    install)
      bake 'ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"'
      ;;

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

      bake brew list | grep -E "^$name$" > /dev/null
      [ "$?" -gt 0 ] && return $STATUS_MISSING
      bake brew outdated | awk '{print $1}' | grep -E "^$name$" > /dev/null
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

