#!/usr/bin/env bats

. lib/functions-text.sh

@test "it returns 0 for regex matches of items in a list" {
  run str_matches "$(ls)" "^Make"
  [ "$status" -eq 0 ]
}
@test "it returns 1 on pattern misses" {
  run str_matches "$(ls)" "^Make$"
  [ "$status" -eq 1 ]
}

