#!/usr/bin/env bats

. test/helpers.sh
loginshell () { . $BORK_SOURCE_DIR/types/loginshell.sh $*; }

@test "loginshell: status returns OK if shell is set to specified value" {
  respond_to "current_shell" "echo foo"
  run loginshell status foo
  [ "$status" -eq $STATUS_OK ]
}

@test "loginshell: status returns MISSING if shell isn't set to specified value" {
  respond_to "current_shell" "echo bar"
  run loginshell status foo
  [ "$status" -eq $STATUS_MISSING ]
}

@test "loginshell: install runs chsh" {
  run loginshell install foo
  [ "$status" -eq 0 ]
  run baked_output
  echo $lines
  [ "${lines[0]}" = "chsh -s foo" ]
}

