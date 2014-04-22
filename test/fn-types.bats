#!/usr/bin/env bats

. test/helpers.sh

operation='echo'

@test "register: recognizes paths" {
  BORK_SCRIPT_DIR="$BORK_WORKING_DIR/test"
  register "./fixtures/custom.sh"
  ok custom
}

@test "register: exits 1 for non-valid values, does not add lib" {
  run register foo
  [ "$status" -eq 1 ]
  run ok foo
  [ "$status" -eq 1 ]
}

# --- lookup_assertion -------------------------------------------
@test "when is_compiled, echoes type_\$assertion" {
  BORK_IS_COMPILED=1
  run lookup_type 'foo'
  [ "$status" -eq 0 ]
  [ "$output" = "type_foo" ]
}

@test "when assertion_types include type, echoes script" {
  bag set assertion_types foo bar
  bag set assertion_types bar bee
  run lookup_type 'foo'
  [ "$status" -eq 0 ]
  [ "$output" = 'bar' ]
}

@test "when references official assertion, echoes that" {
  run lookup_type "git"
  [ "$status" -eq 0 ]
  path="$BORK_SOURCE_DIR/core/git.sh"
  [ "$output" = $path ]
}

@test "when missing and references local script, echoes that" {
  script_path="test/fixtures/custom.sh"
  run lookup_type "$script_path"
  [ "$status" -eq 0 ]
  abs_path="$BORK_SCRIPT_DIR/$script_path"
  [ "$output" = $abs_path ]
}
