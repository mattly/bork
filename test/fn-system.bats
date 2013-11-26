#!/usr/bin/env bats

. test/helpers.sh

@test "has_exec: returns 0 when an exec exists" {
  run has_exec "sh"
  [ "$status" -eq 0 ]
}

@test "has_exec: returns 127 when an exec doesn't exist" {
  run has_exec "nothing_to_see_here_nope_move_right_along"
  [ "$status" -eq 127 ]
}

@test "has_exec: returns 1 if exec doesn't exit cleanly" {
  run has_exec "git --" "foo"
  [ "$status" -eq 1 ]
}

@test "has_exec: returns 0 when exec exists and matches condiditions" {
  run has_exec "cat LICENSE" "Matthew Lyon" "MIT License"
  [ "$status" -eq 0 ]
}

@test "has_exec: returns 2 if exec is present but doesn't match conditions" {
  run has_exec "cat LICENSE" "Matthew Lyon" "GPL"
  [ "$status" -eq 2 ]
}

# == is_platform
@test "is_platform: returns 0 if argument is for platform" {
  expects=$(uname -s)
  run is_platform "$expects"
  [ "$status" -eq 0 ]
}

@test "is_platform: returns 1 if argument is not for platform" {
  run is_platform "HAL9000"
  [ "$status" -eq 1 ]
}

