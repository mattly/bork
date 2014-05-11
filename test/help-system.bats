#!/usr/bin/env bats

. test/helpers.sh

@test "has_exec: returns 0 when an exec exists" {
  run has_exec "sh"
  [ "$status" -eq 0 ]
}

@test "has_exec: returns 10 when an exec doesn't exist" {
  run has_exec "nothing_to_see_here_nope_move_right_along"
  [ "$status" -eq 10 ]
}

@test "has_exec: returns 20 if exec doesn't exit cleanly" {
  run has_exec "git --" "foo"
  [ "$status" -eq 20 ]
}

@test "has_exec: returns 0 when exec exists and matches condiditions" {
  run has_exec "cat LICENSE" "Matthew Lyon" "MIT License"
  [ "$status" -eq 0 ]
}

@test "has_exec: returns 11 if exec is present but doesn't match conditions" {
  run has_exec "cat LICENSE" "Matthew Lyon" "GPL"
  [ "$status" -eq 11 ]
}

# == needs_exec
@test "needs_exec: returns \$2 if exec found" {
  run needs_exec "cat" 0
  [ "$status" -eq 0 ]
  [ -z "$output" ]

  run needs_exec "cat" 11
  [ "$status" -eq 11 ]
  [ -z "$output" ]

  run needs_exec "cat"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "needs_exec: returns \$2 + 1 if exec not found, echoes message" {
  respond_to "which foo" "return 1"

  run needs_exec foo 0
  [ "$status" -eq 1 ]
  str_matches "$output" "^missing.*foo$"

  run needs_exec foo 11
  [ "$status" -eq 12 ]
  str_matches "$output" "^missing.*foo$"

  run needs_exec foo
  [ "$status" -eq 1 ]
  str_matches "$output" "^missing.*foo$"
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

