performed_install=0
performed_upgrade=0
performed_error=0

changes_reset () {
  performed_install=0
  performed_upgrade=0
  performed_error=0
}

changes_complete () {
  status=$1
  action=$2
  if [ "$status" -gt 0 ]; then performed_error=1
  elif [ "$action" = "install" ]; then performed_install=1
  elif [ "$action" = "upgrade" ]; then performed_upgrade=1
  else
    echo "unknown action $2, exiting"
    exit 1
  fi
  [ "$status" -gt 0 ] && echo "* failure" || echo "* success"
}

did_install () { [ "$performed_install" -eq 1 ] && return 0 || return 1; }
did_upgrade () { [ "$performed_upgrade" -eq 1 ] && return 0 || return 1; }
did_update () {
  if did_install; then return 0
  elif did_upgrade; then return 0
  else return 1
  fi
}
