_ok_run () {
  fn=$1
  shift
  if is_compiled; then ($fn $*)
  else (. $fn $*)
  fi
}

_checked_len=0
_checking () {
  check_str="checking: $*"
  _checked_len=${#check_str}
  echo -n "$check_str"$'\r'
}
_checked () {
  report="$*"
  (( pad=$_checked_len - ${#report} ))
  i=1
  while [ "$i" -le $pad ]; do
    report+=" "
    (( i++ ))
  done
  echo "$report"
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
      _checking $assertion $*
      output=$(_ok_run $fn "status" $*)
      status=$?
      _checked "$(_status_for $status): $assertion $*"
      [ "$status" -ne 0 ] && [ -n "$output" ] && echo "$output"
      ;;
    satisfy)
      _checking $assertion $*
      status_output=$(_ok_run $fn "status" $*)
      status=$?
      _checked "$(_status_for $status): $assertion $*"
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


