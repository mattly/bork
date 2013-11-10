#!/usr/bin/env bats

. lib/functions.sh

@test "it returns 0 when an exec exists" {
  run has_exec "sh"
  [ "$status" -eq 0 ]
}

@test "it returns 1 when an exec doesn't exist" {
  run has_exec "nothing_to_see_here_nope_move_right_along"
  [ "$status" -eq 1 ]
}
