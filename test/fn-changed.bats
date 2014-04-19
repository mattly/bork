#!/usr/bin/env bats

. test/helpers.sh

@test "did_install reflects \$performed_install" {
  performed_install=1
  run did_install
  [ "$status" -eq 0 ]
  performed_install=0
  run did_install
  [ "$status" -eq 1 ]
}

@test "did_upgrade reflects \$performed_upgrade" {
  performed_upgrade=1
  run did_upgrade
  [ "$status" -eq 0 ]
  performed_upgrade=0
  run did_upgrade
  [ "$status" -eq 1 ]
}

@test "did_update reflects both install/upgrade" {
  performed_install=1
  run did_update
  [ "$status" -eq 0 ]
  performed_install=0
  performed_upgrade=1
  run did_update
  [ "$status" -eq 0 ]
  performed_upgrade=0
  run did_update
  [ "$status" -eq 1 ]
}
