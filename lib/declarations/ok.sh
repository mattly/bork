_ok_run () {
  fn=$1
  shift
  if is_compiled; then (cd $BORK_DESTINATION; $fn $*)
  else (cd $BORK_DESTINATION; . $fn $*)
  fi
}

_checked_len=0
_checking () {
  type=$1
  shift
  check_str="$type: $*"
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

_conflict_approve () {
  if [ -n "$BORK_CONFLICT_RESOLVE" ]; then
    return $BORK_CONFLICT_RESOLVE
  fi
  echo
  echo "== Warning! Assertion: $*"
  echo "Attempting to satisfy has resulted in a conflict.  Satisfying this may overwrite data."
  _yesno "Do you want to continue?"
  return $?
}

_yesno () {
  answered=0
  answer=
  while [ "$answered" -eq 0 ]; do
    read -p "$* (yes/no) " answer
    if [[ "$answer" == 'y' || "$answer" == "yes" || "$answer" == "n" || "$answer" == "no" ]]; then
      answered=1
    else
      echo "Valid answers are: yes y no n" >&2
    fi
  done
  [[ "$answer" == 'y' || "$answer" == 'yes' ]]
}

ok () {
  assertion=$1
  shift
  _changes_reset
  fn=$(_lookup_type $assertion)
  if [ -z "$fn" ]; then
    echo "not found: $assertion" 1>&2
    return 1
  fi
  case $operation in
    echo) echo "$fn $*" ;;
    status)
      _checking "checking" $assertion $*
      output=$(_ok_run $fn "status" $*)
      status=$?
      _checked "$(_status_for $status): $assertion $*"
      [ "$status" -ne 0 ] && [ -n "$output" ] && echo "$output"
      return $status ;;
    satisfy)
      _checking "checking" $assertion $*
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
        20)
          echo "$status_output"
          _conflict_approve $assertion $*
          if [ "$?" -eq 0 ]; then
            echo "Resolving conflict..."
            _ok_run $fn upgrade $*
            _changes_complete $? 'upgrade'
          else
            echo "Conflict unresolved."
          fi
          ;;
        *)
          echo "-- sorry, bork doesn't handle this response yet"
          echo "$status_output"
          ;;
      esac
      if did_update; then
        echo "verifying $last_change_type: $assertion $*"
        output=$(_ok_run $fn "status" $*)
        status=$?
        if [ "$status" -gt 0 ]; then
          echo "* $last_change_type failed"
          _checked "$(_status_for $status)"
          echo "$output"
        else
          echo "* success"
        fi
        return 1
      fi
      ;;
  esac
}


