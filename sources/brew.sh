cmd="command brew"

$(str_contains "$($cmd list)" "$1")
__brew_pkg_is_installed=$?
$(str_contains "$($cmd outdated | awk '{print $1}')" "$1")
__brew_pkg_is_outdated=$?

mode=$(bork_mode)
case $mode in
  depends) echo "pkg: brew" ;;
  status)
    [[ $__brew_pkg_is_installed > 0 ]] && return 10
    [[ $__brew_pkg_is_outdated = 0 ]] && return 11
    return 0
    ;;
  satisfy) ;;
esac


# from old version, keeping it around until all functionality merged in
# brew () {
#   local pkg=${1}
#   local c=''
#   if contains "$brews_have" "$pkg" ; then
#     if contains "$brews_outdated" "$pkg" ; then
#       bake "command brew upgrade $pkg"
#     fi
#   else
#     bake "command brew install $*"
#   fi
# }
# brews_have=$(command brew list)
# brews_outdated=$(command brew outdated | awk '{print $1}')
# brew_taps=$(command brew tap)

# brew_tap () {
#   if ! contains "$brew_taps" $1 ; then
#     bake "command brew tap $1"
#   fi
# }

