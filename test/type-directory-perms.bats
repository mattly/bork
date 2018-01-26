#!/usr/bin/env bats

. test/helpers.sh
directory () { . $BORK_SOURCE_DIR/types/directory.sh $*; }

setup() {
  respond_to "stat --printf %U\\\n%G\\\n%a foo" "printf '%s\n%s\n%s' user users 755"
}

@test "directory: status returns MISMATCH_UPGRADE when target directory has incorrect owner" {
  run directory status foo --owner=bork
  (( status == STATUS_MISMATCH_UPGRADE ))
  [[ ${lines[0]} == 'expected owner: bork' ]]
  [[ ${lines[1]} == 'received owner: user' ]]
}

@test "directory: status returns MISMATCH_UPGRADE when target directory has incorrect group" {
  run directory status foo --group=bork
  (( status == STATUS_MISMATCH_UPGRADE ))
  [[ ${lines[0]} == 'expected group: bork' ]]
  [[ ${lines[1]} == 'received group: users' ]]
}

@test "directory: status returns MISMATCH_UPGRADE when target directory has incorrect mode" {
  run directory status foo --mode=700
  (( status == STATUS_MISMATCH_UPGRADE ))
  [[ ${lines[0]} == 'expected mode: 700' ]]
  [[ ${lines[1]} == 'received mode: 755' ]]
}

@test "directory: status returns OK when everything matches" {
  run directory status foo --owner=user --group=users --mode=755
  (( status == STATUS_OK ))
}

@test "directory: install sets owner for directory" {
  run directory install foo --owner=bork
  (( status == 0 ))
  run baked_output
  [[ ${lines[-1]} =~ ^sudo\ install ]]
  [[ ${lines[-1]} =~ '-o bork' ]]
}

@test "directory: install sets group for directory" {
  run directory install foo --group=bork
  (( status == 0 ))
  run baked_output
  [[ ${lines[-1]} =~ ^sudo\ install ]]
  [[ ${lines[-1]} =~ '-g bork' ]]
}

@test "directory: install sets mode for directory" {
  run directory install foo --mode=700
  (( status == 0 ))
  run baked_output
  [[ ${lines[-1]} =~ ^install ]]
  [[ ${lines[-1]} =~ '-m 700' ]]
}
