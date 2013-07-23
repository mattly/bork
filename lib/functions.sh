contains () {
  matches "$1" "^$2\$"
}

matches () {
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

current_destination=$PWD
set_dir () {
  current_destination=$1
}
unset_dir () {
  current_destination=$PWD
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

baking_dir=$PWD
bake_at () {
  baking_dir=$1
}
bake () {
  opdir=$PWD

  if matches "$1" "^--dir"; then
    opdir="$2"
    shift 2
  fi

  if [ $operation = 'install' ]; then
    echo "$1"
    (
      cd $opdir
      $1
    )
    status="$(echo $?)"
    if [ "$status" -gt "0" ]; then
      exit $status
    fi
  elif [ $operation = 'print' ]; then
    echo "$1"
  fi
}
