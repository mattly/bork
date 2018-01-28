_source_runner () {
  if is_compiled; then echo "$1"
  else echo ". $1"
  fi
}

_bork_check_failed=0
check_failed () { [ "$_bork_check_failed" -gt 0 ] && return 0 || return 1; }

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
  _bork_check_failed=0
  _changes_reset
  fn=$(_lookup_type $assertion)
  if [ -z "$fn" ]; then
    echo "not found: $assertion" 1>&2
    return 1
  fi
  argstr=$@
  quoted_argstr=''
  for i in "$@"; do
      case "$i" in
          *\'*)
              i=`printf "%s" "$i" | sed "s/'/'\"'\"'/g"`
              ;;
          *) : ;;
      esac
      quoted_argstr="$quoted_argstr '$i'"
  done
  case $operation in
    echo) echo "$fn $argstr" ;;
    status)
      _checking "checking" $assertion $argstr
      output=$(eval "$(_source_runner $fn) status $quoted_argstr")
      status=$?
      _checked "$(_status_for $status): $assertion $argstr"
      [ "$status" -eq 1 ] && _bork_check_failed=1
      [ "$status" -ne 0 ] && [ -n "$output" ] && echo "$output"
      return $status ;;
    satisfy)
      _checking "checking" $assertion $argstr
      status_output=$(eval "$(_source_runner $fn) status $quoted_argstr")
      status=$?
      _checked "$(_status_for $status): $assertion $argstr"
      case $status in
        0) : ;;
        1)
          _bork_check_failed=1
          echo "$status_output"
          ;;
        10)
          eval "$(_source_runner $fn) install $quoted_argstr"
          _changes_complete $? 'install'
          ;;
        11|12|13)
          echo "$status_output"
          eval "$(_source_runner $fn) upgrade $quoted_argstr"
          _changes_complete $? 'upgrade'
          ;;
        20)
          echo "$status_output"
          _conflict_approve $assertion $argstr
          if [ "$?" -eq 0 ]; then
            echo "Resolving conflict..."
            eval "$(_source_runner $fn) upgrade $quoted_argstr"
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
        echo "verifying $last_change_type: $assertion $argstr"
        output=$(eval "$(_source_runner $fn) status $quoted_argstr")
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
