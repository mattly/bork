status_for () {
  case "$1" in
    "0")  echo "ok" ;;
    "10") echo "missing" ;;
    "11") echo "outdated" ;;
    "20") echo "conflict" ;;
    *)    echo "unknown status: $1" ;;
  esac
}

ok_run () {
  fn=$1
  shift
  if is_compiled; then $fn $*
  else . $fn $*
  fi
}
ok () {
  assertion=$1
  shift
  changes_reset
  baking_dir=$PWD
  fn=$(lookup_type $assertion)
  if [ "$?" -gt 0 ]; then return 1; fi
  case $operation in
    echo) echo $fn $* ;;
    status)
      output=$(ok_run $fn "status" $*)
      status=$?
      echo "$(status_for $status): $assertion $*"
      [ "$status" -ne 0 ] && [ -n "$output" ] && echo "$output"
      ;;
    satisfy)
      echo "checking status: $assertion $*"
      status_output=$(ok_run $fn "status" $*)
      status=$?
      echo "$(status_for $status): $assertion $*"
      case $status in
        0) : ;;
        10)
          ok_run $fn install $*
          changes_complete $? 'install'
          ;;
        11)
          echo "$status_output"
          ok_run $fn upgrade $*
          changes_complete $? 'upgrade'
          ;;
        20)
          echo "* $status_output"
          ;;
      esac
      clean_tmpdir
      baking_dir=
      baking_user=
      ;;
    compile)
      echo "# compiling 'ok $assertion $*'"
      assertion=$(basename $assertion '.sh')
      include_assertion $assertion $fn
      ok_run $fn compile $*
      echo "ok $assertion $*"
      ;;
  esac
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
baking_user=
bake_in () { baking_dir=$1; }
bake_as () { baking_user=$1; }
bake () {
  this_cmd=
  [ -n "$baking_dir" ] && this_cmd="cd $baking_dir &&"
  [ -n "$baking_user" ] && this_cmd="$this_cmd sudo -u $baking_user sh -c '"
  this_cmd="$this_cmd$1"
  [ -n "$baking_user" ] && this_cmd="$this_cmd'"
  echo "$this_cmd"
  (eval $this_cmd)
  status="$(echo $?)"
  if [ "$status" -gt "0" ]; then
    echo "failed with status: $status"
    exit $status
  fi
}
