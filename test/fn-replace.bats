#!/usr/bin/env bats

. lib/functions.sh

@test "it replaces the matched pattern with the result" {
  result=$(replace "foobar" "o*b" "at")
  [ "$result" = "fatar" ]
}

@test "it returns the input when the pattern does not match" {
  result=$(replace "foobar" "aa" "bb")
  [ "$result" = "foobar" ]
}
