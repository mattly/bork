#!/bin/bash
includes () {
  present=$(echo "$1" | grep -e "$2" > /dev/null)
  return $present
}

replace () {
  echo $(echo "$1" | sed -E 's/'"$2"'/'"$3"'/')
}

get_field () {
  echo $(echo "$1" | awk '{print $'"$2"'}')
}

get_directory () {
  echo $(eval "echo $1")
}

brew () {
  local pkg=${1}
  local c=''
  if includes "$brews_have" "$pkg" ; then
    if includes "$brews_outdated" "$pkg" ; then
      c="brew upgrade $pkg"
    fi
  else
    c="brew install $@"
  fi
  if [ -n "$c" ] ; then echo "command $c" ; fi
}
brews_have=$(command brew list)
brews_outdated=$(command brew outdated | awk '{print $1}')

github () {
  repo=$1
  dir=$(get_directory $2)
  if [ ! -d $dir ]; then
    echo mkdir -p $dir
    c="git clone --bare https://github.com/$(echo $repo).git $dir"
  else
    c="cd $dir && git pull"
  fi
  if [ -n "$c" ] ; then echo $c ; fi
}


nodenv () {
  if ! includes "$(command nodenv versions --bare )" $1; then
    echo $(command nodenv install $1)
  fi
}

rbenv () {
  if ! includes "$(command rbenv versions --bare )" $1; then
    echo $(command rbenv install $1)
  fi
}


. $1
