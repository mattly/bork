#!/usr/bin/env bats

. test/helpers.sh

operation='echo'

@test "checks against core types" {
  run ok directories foo
  [ "$status" -eq 0 ]
  [ "$BORK_SOURCE_DIR/core/directories.sh foo" = $output ]
}

@test "checks against stdlib_types" {
  use brew
  run ok brew foo
  [ "$status" -eq 0 ]
  [ "$BORK_SOURCE_DIR/stdlib/brew.sh foo" = $output ]
}

@test "checks against registered types" {
  BORK_SCRIPT_DIR="$BORK_SOURCE_DIR/test"
  use "fixtures/custom.sh"
  ok custom
}
