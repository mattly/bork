#!/usr/bin/env bats

. test/helpers.sh

operation='echo'

@test "use: recognizes stdlib types" {
  use brew apt git
  ok brew
  ok apt
  ok git
}

@test "use: recognizes paths" {
  BORK_SCRIPT_DIR="$BORK_WORKING_DIR/test"
  use "./fixtures/custom.sh"
  ok custom
}

@test "use: returns 1 for non-valid values, does not add lib" {
  status=$(use foo; echo $?)
  [ "$status" -eq 1 ]
  run ok foo
  [ "$status" -eq 1 ]
}
