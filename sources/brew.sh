brew () {
  local pkg=${1}
  local c=''
  if contains "$brews_have" "$pkg" ; then
    if contains "$brews_outdated" "$pkg" ; then
      bake "command brew upgrade $pkg"
    fi
  else
    bake "command brew install $*"
  fi
}
brews_have=$(command brew list)
brews_outdated=$(command brew outdated | awk '{print $1}')
brew_taps=$(command brew tap)

brew_tap () {
  if ! contains "$brew_taps" $1 ; then
    bake "command brew tap $1"
  fi
}

