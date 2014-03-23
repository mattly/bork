#!/usr/bin/env bats

. test/helpers.sh

operation='echo'

@test "ok: checks against core types" {
  run ok directories foo
  [ "$status" -eq 0 ]
  [ "$BORK_SOURCE_DIR/core/directories.sh foo" = $output ]
}

@test "ok: checks against stdlib_types" {
  run ok brew foo
  [ "$status" -eq 0 ]
  [ "$BORK_SOURCE_DIR/core/brew.sh foo" = $output ]
}

@test "ok: checks against registered types" {
  BORK_SCRIPT_DIR="$BORK_SOURCE_DIR/test"
  register "fixtures/custom.sh"
  ok custom
}
