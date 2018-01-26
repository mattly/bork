#!/bin/bash

action=$1
name=$2
shift 2

case "${action}" in
  desc)
    printf '%s\n' \
      'asserts presence of packages installed via zypper (SUSE)' \
      '* zypper packge-name    (install/upgrade given package)'
    ;;
  status)
    needs_exec "rpm" || return "${STATUS_FAILED_PRECONDITION}"
    needs_exec "zypper" || return "${STATUS_FAILED_PRECONDITION}"

    bake rpm -q "${name}" &>/dev/null || return "${STATUS_MISSING}"
    ! bake zypper --terse list-updates | egrep -q " ${name} " \
      || return "${STATUS_OUTDATED}"
    return "${STATUS_OK}"
    ;;
  install|upgrade|delete)
    case "${action}" in
      upgrade) action="update" ;;
      delete) action="remove" ;;
    esac
    bake sudo zypper -nt "${action}" "${name}"
    ;;
  *) return 1 ;;
esac
