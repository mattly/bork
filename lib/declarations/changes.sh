bork_performed_install=0
bork_performed_upgrade=0
bork_performed_error=0

bork_any_updated=0

did_install () { [ "$bork_performed_install" -eq 1 ] && return 0 || return 1; }
did_upgrade () { [ "$bork_performed_upgrade" -eq 1 ] && return 0 || return 1; }
did_update () {
  if did_install; then return 0
  elif did_upgrade; then return 0
  else return 1
  fi
}
did_error () { [ "$bork_performed_error" -gt 0 ] && return 0 || return 1; }

any_updated () { [ "$bork_any_updated" -gt 0 ] && return 0 || return 1; }

_changes_reset () {
  bork_performed_install=0
  bork_performed_upgrade=0
  bork_performed_error=0
  last_change_type=
}

_changes_complete () {
  status=$1
  action=$2
  if [ "$status" -gt 0 ]; then bork_performed_error=1
  elif [ "$action" = "install" ]; then bork_performed_install=1
  elif [ "$action" = "upgrade" ]; then bork_performed_upgrade=1
  fi
  if did_update; then bork_any_updated=1 ;fi
  [ "$status" -gt 0 ] && echo "* failure"
}

