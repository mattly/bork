# TODO write tests for the packageless 'brew' assertion
# TODO specify install/upgrade options, such as --env, --cc, etc
# TODO would handling --cc etc also handle package options such as --with-spacemacs-icon on emacs-mac ?

action=$1
name=$2
shift 2
from=$(arguments get from $*)

if [ -z "$name" ]; then
  case $action in
    desc)
      echo "asserts presence of packages installed via homebrew on mac os x"
      echo "* brew                  (installs/updates homebrew)"
      echo "* brew package-name     (installs package)"
      ;;
    status)
      baking_platform_is "Darwin" || return $STATUS_UNSUPPORTED_PLATFORM
      needs_exec "ruby" || return $STATUS_FAILED_PRECONDITION
      path=$(bake which brew)
      [ "$?" -gt 0 ] && return $STATUS_MISSING
      bake brew update && return $STATUS_OK || return $STATUS_FAILED
      ;;

    install)
      bake 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
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

    install)
      if [ -z "$from" ]; then
        HOMEBREW_NO_AUTO_UPDATE=true bake brew install $name
      else
        HOMEBREW_NO_AUTO_UPDATE=true bake brew install $from/$name
      fi
      ;;

    upgrade) HOMEBREW_NO_AUTO_UPDATE=true bake brew upgrade $name ;;

    *) return 1 ;;
  esac
fi
