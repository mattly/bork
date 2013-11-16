# TODO
# specifying brew install/upgrade options, such as --env --cc, etc
# specifying / comapring package options, f.e.
#   reattach-to-user-namespace's --wrap-pbcopy-and-pbpaste option
#   if differs, should be some other 1? option code
# specifying a formula should be taken from a tap
#   not sure if specifying taps themselves would be entirely useful

cmd="command brew"

action=$1
name=$2
shift 2

brew_status () {
  $(str_contains "$($cmd list)" "$name")
  [ "$?" -gt 0 ] && return 10
  $(str_contains "$($cmd outdated | awk '{print $1}')" "$name")
  [ "$?" -eq 0 ] && return 11
  return 0
}

case $action in
  depends) echo "pkg: brew" ;;
  status)
    brew_status
    return $? ;;
  install) bake "$cmd install $name" ;;
  upgrade) bake "$cmd upgrade $name" ;;
  *) return 1 ;;
esac


# from old version, keeping it around until all functionality merged in
# brew_taps=$(command brew tap)

# brew_tap () {
#   if ! contains "$brew_taps" $1 ; then
#     bake "command brew tap $1"
#   fi
# }

