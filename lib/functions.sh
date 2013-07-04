includes () {
  present=$(echo "$1" | grep -e "$2" > /dev/null)
  return $present
}

replace () {
  echo $(echo "$1" | sed -E 's|'"$2"'|'"$3"'|')
}

substring () {
  echo $(expr "$1" : $2)
}

get_field () {
  echo $(echo "$1" | awk '{print $'"$2"'}')
}

get_directory () {
  echo $(eval "echo $1")
}

include () {
  if [ -e "$scriptDir/$1" ]; then
    # if [ $operation = 'build' ]; then
    #   echo "$scriptDir/$1"
    # else
      . "$scriptDir/$1"
    # fi
  else
    echo "include: $scriptDir/$1: No such file or directory"
    exit 1
  fi
}

bake () {
  if [ $operation = 'install' ]; then
    echo "$(1)"
  elif [ $operation = 'print' ]; then
    echo "$1"
  fi
}
