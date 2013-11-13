#!/usr/bin/env bats

. lib/arguments.sh

@test "parse extracts the main argument" {
  skip
}

@test "parse extracts subsequent --arguments" {
  skip
}

@test "get returns a value" {
  skip
}

@test "unknown command returns 1" {
  run arguments
  [ "$status" -eq 1 ]
}

