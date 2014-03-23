#!/usr/bin/env bats

. test/helpers.sh

operation='echo'

@test "register: recognizes paths" {
  BORK_SCRIPT_DIR="$BORK_WORKING_DIR/test"
  register "./fixtures/custom.sh"
  ok custom
}

@test "register: returns 1 for non-valid values, does not add lib" {
  status=$(register foo; echo $?)
  [ "$status" -eq 1 ]
  run ok foo
  [ "$status" -eq 1 ]
}
