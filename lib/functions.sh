status_for () {
  case "$1" in
    "0")  echo "ok" ;;
    "10") echo "missing" ;;
    "11") echo "outdated" ;;
    "20") echo "conflict" ;;
    *)    echo "unknown status: $?" ;;
  esac
}

stdlib_types=""
assertion_types=""

register () {
  for file in $*; do
    type=$(basename $file '.sh')
    if [ -e "$BORK_SCRIPT_DIR/$file" ]; then
      file="$BORK_SCRIPT_DIR/$file"
    else
      return 1
    fi
    assertion_types=$(echo "$assertion_types"; echo "$type=$file")
  done
}

get_val () {
  echo "$assertion_types" | while read line; do
    key=${line%%=*}
    if [ "$key" = $1 ]; then
      echo "${line##*=}"
      return 0
    fi
  done
}

ok () {
  assertion=$1
  shift
  performed_install=0
  performed_upgrade=0
  encountered_error=0
  baking_dir=$PWD
  fn=$(get_val $assertion)
  if [ -z $fn ] &&
    [ -e "$BORK_SOURCE_DIR/core/$(echo $assertion).sh" ]; then
    fn="$BORK_SOURCE_DIR/core/$(echo $assertion).sh"
  fi
  if [ -z $fn ]; then
    echo "invalid type $assertion not found in $assertion_types"
    return 1
  else
    case $operation in
      echo) echo $fn $* ;;
      status)
        output=$(. $fn "status" $*)
        status=$?
        echo "$(status_for $status): $assertion $*"
        [ "$status" -eq 20 ] && echo "* $output"
        ;;
      satisfy)
        status_output=$(. $fn "status" $*)
        status=$?
        echo "$(status_for $status): $assertion $*"
        case $status in
          0) : ;;
          10)
            . $fn install $*
            [ "$?" -eq 0 ] && performed_install=1 || encountered_error=0
            ;;
          11)
            . $fn upgrade $*
            [ "$?" -eq 0 ] && performed_ugprade=1 || encountered_error=0
            ;;
          20)
            echo "* $status_output"
            ;;
        esac
        clean_tmpdir
        ;;
    esac
  fi
}

pkg () {
  name=$1
  $(bork_pkg_$name depends >> /dev/null 2>&1)
  present=$?
  if [ "$present" -eq 0 ]; then
    shift
    pkg_runner "bork_pkg_$name" "$name" $*
  else
    case $platform in
      Darwin) manager="brew" ;;
      Linux)
        if has_exec "apt-get"; then manager="apt"
        else return 1
        fi ;;
      *) return 1 ;;
    esac
    ok $manager $*
  fi
}

did_install () { [ "$performed_install" -eq 1 ] && return 0 else return 1; }
did_upgrade () { [ "$performed_upgrade" -eq 1 ] && return 0 else return 1; }
did_update () {
  if did_install; then return 0
  elif did_upgrade; then return 0
  else return 1
  fi
}

# TODO maybe script dir should be a stack?
include () {
  if [ -e "$BORK_SCRIPT_DIR/$1" ]; then
    # if [ $operation = 'build' ]; then
    #   echo "$scriptDir/$1"
    # else
      . "$BORK_SCRIPT_DIR/$1"
    # fi
  else
    echo "include: $BORK_SCRIPT_DIR/$1: No such file or directory"
    exit 1
  fi
}

baking_dir=
bake_in () { baking_dir=$1; }
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
