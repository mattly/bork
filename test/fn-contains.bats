#!/usr/bin/env bats

. lib/functions.sh

@test "it returns 0 for full matches of items in a list" {
  run contains "$(ls)" "Makefile"
  [ "$status" -eq 0 ]
}
@test "it returns 1 when no full matches" {
  run contains "$(ls)" "Make"
  [ "$status" -eq 1 ]
}
