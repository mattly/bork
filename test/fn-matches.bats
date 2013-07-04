#!/usr/bin/env bats

. lib/functions.sh

@test "it returns 0 for regex matches of items in a list" {
  run matches "$(ls)" "^Make"
  [ "$status" -eq 0 ]
}
@test "it returns 1 on pattern misses" {
  run matches "$(ls)" "^Make$"
  [ "$status" -eq 1 ]
}

