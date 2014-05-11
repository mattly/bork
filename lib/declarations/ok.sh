_ok_run () {
  fn=$1
  shift
  if is_compiled; then ($fn $*)
  else (. $fn $*)
  fi
}

ok () {
  assertion=$1
  shift
  _changes_reset
  fn=$(_lookup_type $assertion)
  [ -z "$fn" ] && return 1
  case $operation in
    echo) echo "$fn $*" ;;
    status)
      output=$(_ok_run $fn "status" $*)
      status=$?
      echo "$(_status_for $status): $assertion $*"
      [ "$status" -ne 0 ] && [ -n "$output" ] && echo "$output"
      ;;
    satisfy)
      check="checking: $assertion $*"
      len=${#check}
      echo -n $check$'\r'
      status_output=$(_ok_run $fn "status" $*)
      status=$?
      report="$(_status_for $status): $assertion $*"
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
          _ok_run $fn install $*
          _changes_complete $? 'install'
          ;;
        11|12|13)
          echo "$status_output"
          _ok_run $fn upgrade $*
          _changes_complete $? 'upgrade'
          ;;
        *)
          echo "* $status_output"
          ;;
      esac
      clean_tmpdir
      ;;
  esac
}


