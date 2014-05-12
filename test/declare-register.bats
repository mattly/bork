#!/usr/bin/env bats

. test/helpers.sh

operation='echo'

is_compiled () { [ -n "$is_compiled" ]; }

@test "register: recognizes paths" {
  BORK_SCRIPT_DIR="$BORK_WORKING_DIR/test"
  register "./fixtures/custom.sh"
  ok custom foo
}

@test "register: exits 1 for non-valid values, does not add lib" {
  run register foo
  [ "$status" -eq 1 ]
  run ok foo
  [ "$status" -eq 1 ]
}

# --- lookup_assertion -------------------------------------------
@test "lookup_type: when is_compiled, echoes type_\$assertion" {
  is_compiled=true
  run _lookup_type 'foo'
  [ "$status" -eq 0 ]
  [ "$output" = "type_foo" ]
}

@test "lookup_type: when assertion_types include type, echoes script" {
  bag set bork_assertion_types foo bar
  bag set bork_assertion_types bar bee
  run _lookup_type 'foo'
  [ "$status" -eq 0 ]
  [ "$output" = 'bar' ]
}

@test "lookup_type: when references official assertion, echoes that" {
  run _lookup_type "git"
  [ "$status" -eq 0 ]
  path="$BORK_SOURCE_DIR/types/git.sh"
  [ "$output" = $path ]
}

@test "when missing and references local script, echoes that" {
  script_path="test/fixtures/custom.sh"
  run _lookup_type "$script_path"
  [ "$status" -eq 0 ]
  abs_path="$BORK_SCRIPT_DIR/$script_path"
  [ "$output" = $abs_path ]
}
