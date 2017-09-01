action=$1
name=$2
shift 2
appdir=$(arguments get appdir $*)

case $action in
  desc)
    echo "asserts presenece of apps installed via caskroom.io on Mac OS X"
    echo "* cask app-name         (installs cask)"
    echo "--appdir=/Applications  (changes symlink path)"
    ;;

  status)
    baking_platform_is "Darwin" || return $STATUS_UNSUPPORTED_PLATFORM
    needs_exec "brew" || return $STATUS_FAILED_PRECONDITION
    bake brew cask --version > /dev/null
    [ "$?" -gt 0 ] && return $STATUS_FAILED_PRECONDITION

    list=$(bake brew cask list)
    echo "$list" | grep -E "^$name$" > /dev/null
    [ "$?" -gt 0 ] && return $STATUS_MISSING

    info=$(bake brew cask info $name)
    echo "$info" | grep 'Not installed' > /dev/null
    # TODO replace with perhaps "OUTDATED_CLOBBER" ?
    [ "$?" -eq 0 ] && return $STATUS_OUTDATED

    return 0 ;;

  install)
    if [ -n "$appdir"  ]; then
      bake brew cask install $name --appdir=$appdir
    else
      bake brew cask install $name
    fi
    ;;

  upgrade)
    # TODO move rm statement to remove action with clobber
    bake rm -rf "/opt/homebrew-cask/Caskroom/$name"
    if [ -n "$appdir" ]; then
      bake brew cask install $name --appdir=$appdir --force
    else
      bake brew cask install $name --force
    fi
    ;;

  *) return 1 ;;
esac
