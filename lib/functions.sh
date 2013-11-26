status_for () {
  case "$1" in
    "0")  echo "current" ;;
    "10") echo "missing" ;;
    "11") echo "outdated" ;;
    "20") echo "conflict" ;;
    *)    echo "unknown status: $?" ;;
  esac
}

pkg () {
  name=$1
  $(bork_pkg_$name >> /dev/null 2>&1)
  present=$?
  if [ "$present" -eq 0 ]; then
    shift
    pkg_runner "bork_pkg_$name" "$name" $*
  else
    case $platform in
      Darwin) manager="brew" ;;
    esac
    pkg_runner "bork_decl_$manager" "pkg" $*
  fi
}

performed_install=0
performed_upgrade=0
pkg_runner () {
  performed_install=0
  performed_upgrade=0
  fn=$1
  pretty=$2
  shift 2
  baking_dir=$PWD
  case $operation in
    status)
      $fn status $*
      echo "$(status_for $?): $pretty $*"
      ;;
    satisfy)
      $fn status $*
      status=$?
      case $status in
        0) : ;;
        10)
          echo "---------------------------------"
          echo "Package $1 missing. Installing..."
          $fn install $*
          [ "$?" -eq 0 ] && performed_install=1
          ;;
        11)
          echo "---------------------------------"
          echo "Package $1 outdated. Upgrading..."
          $fn upgrade $*
          [ "$?" -eq 0 ] && performed_upgrade=1
          ;;
        20)
          echo "---------------------------------"
          echo "Package $1 conflicted. Please resolve manually."
          ;;
      esac
      ;;
  esac
}

did_install () { [ "$performed_install" -eq 1 ] && return 0 else return 1; }
did_upgrade () { [ "$performed_upgrade" -eq 1 ] && return 0 else return 1; }
did_update () {
  if did_install; then return 0
  elif did_upgrade; then return 0
  else return 1
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

baking_dir=
bake_in () {
  baking_dir=$1
}
bake () {
  echo "$1"
  (
    cd $baking_dir
    $1
  )
  status="$(echo $?)"
  if [ "$status" -gt "0" ]; then
    echo "failed with status: $status"
    exit $status
  fi
}
