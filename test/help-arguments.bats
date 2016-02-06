#!/usr/bin/env bats

. test/helpers.sh

@test "get echoes a value when present" {
  result=$(arguments get foo thing --foo=bar)
  [ "$result" = "bar" ]
}

@test "get echoes nothing when not present" {
  result=$(arguments get bar thing --foo=bar)
  [ -z "$result" ]
}

@test "get echoes 'true' when no equal sign" {
  result=$(arguments get foo --foo)
  [ "$result" = "true" ]
}

@test "unknown command returns 1" {
  run arguments
  [ "$status" -eq 1 ]
}

