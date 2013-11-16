#!/usr/bin/env bats

. lib/functions-text.sh
. lib/arguments.sh

@test "get echoes a value when present" {
  result=$(arguments get foo thing --foo=bar)
  [ "$result" = "bar" ]
}

@test "get echoes nothing when not present" {
  result=$(arguments get bar thing --foo=bar)
  [ -z "$result" ]
}

@test "unknown command returns 1" {
  run arguments
  [ "$status" -eq 1 ]
}

