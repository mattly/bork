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
  if is_compiled; then ($fn $*)
  else (. $fn $*)
  fi
}

ok () {
  assertion=$1
  shift
  changes_reset
  fn=$(lookup_type $assertion)
  [ -z "$fn" ] && return 1
  case $operation in
    echo) echo "$fn $*" ;;
    status)
      output=$(ok_run $fn "status" $*)
      status=$?
      echo "$(status_for $status): $assertion $*"
      [ "$status" -ne 0 ] && [ -n "$output" ] && echo "$output"
      ;;
    satisfy)
      check="checking: $assertion $*"
      len=${#check}
      echo -n $check$'\r'
      status_output=$(ok_run $fn "status" $*)
      status=$?
      report="$(status_for $status): $assertion $*"
      (( pad=$len-${#report} ))
      i=1
      while [ "$i" -le $pad ]; do
        report+=" "
        (( i++ ))
      done
      echo $report
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
      ;;
  esac
}


