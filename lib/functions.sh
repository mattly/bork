status_for () {
  case "$1" in
    "0")  echo "current" ;;
    "10") echo "missing" ;;
    "11") echo "outdated" ;;
    "20") echo "conflict" ;;
    *)    echo "unknown status: $?" ;;
  esac
}

bork_mode () {
  [ -z "$this_op" ] && echo $bork_operation || echo $this_op
}

pkg () {
  name=$1
  this_op='depends'
  $(bork_pkg_$name 2>&1 > /dev/null)
  present=$?
  this_op=''
  if [ "$present" -eq 0 ]; then
    shift
    pkg_runner "bork_pkg_$name" "$name" $*
  else
    case $platform in
      Darwin) manager="brew" ;;
    esac
    pkg_runner "src_$manager" "pkg" $*
  fi
}

pkg_runner () {
  fn=$1
  pretty=$2
  shift 2
  $fn $*
  ret=$?
  if [ "$(bork_mode)" = 'status' ]; then
    echo "$(status_for $ret): $pretty $*"
  fi
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
