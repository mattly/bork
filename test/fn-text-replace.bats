#!/usr/bin/env bats

. lib/functions-text.sh

@test "it replaces the matched pattern with the result" {
  result=$(str_replace "foobar" "o*b" "at")
  [ "$result" = "fatar" ]
}

@test "it returns the input when the pattern does not match" {
  result=$(str_replace "foobar" "aa" "bb")
  [ "$result" = "foobar" ]
}
