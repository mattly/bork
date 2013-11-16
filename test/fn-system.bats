#!/usr/bin/env bats

. test/helpers.sh

@test "has_exec: returns 0 when an exec exists" {
  run has_exec "sh"
  [ "$status" -eq 0 ]
}

@test "has_exec: returns 1 when an exec doesn't exist" {
  run has_exec "nothing_to_see_here_nope_move_right_along"
  [ "$status" -eq 1 ]
}

@test "is_platform: returns 0 if argument is for platform" {
  expects=$(uname -s)
  run is_platform "$expects"
  [ "$status" -eq 0 ]
}

@test "is_platform: returns 1 if argument is not for platform" {
  run is_platform "HAL9000"
  [ "$status" -eq 1 ]
}

@test "check_output_for: returns 1 if binary is missing" {
  run check_output_for "this_command_doesnt_exist" "Matthew Lyon" "Something Else"
  [ "$status" -eq 1 ]
}
@test "check_output_for: returns 1 if binary is present but match conditions" {
  run check_output_for "cat LICENSE" "Matthew Lyon" "GPL"
  [ "$status" -eq 1 ]
}
@test "check_output_for: returns 0 if binary is present and matches conditions" {
  run check_output_for "cat LICENSE" "Matthew Lyon" "MIT License"
  [ "$status" -eq 0 ]
}
