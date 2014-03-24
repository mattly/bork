#!/usr/bin/env bats

. test/helpers.sh

operation='echo'
BORK_SCRIPT_DIR="$BORK_SOURCE_DIR/test"

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

@test "ok: checks against local scripts" {
  run ok fixtures/custom.sh foo
  [ "$status" -eq 0 ]
  [ "$BORK_SCRIPT_DIR/fixtures/custom.sh foo" = $output ]
}

@test "ok: checks against registered types" {
  register fixtures/custom.sh
  run ok custom foo
  [ "$status" -eq 0 ]
  [ "$BORK_SCRIPT_DIR/fixtures/custom.sh foo" = $output ]
}
