#!/usr/bin/env bats

. test/helpers.sh

# == Contains
@test "contains: returns 0 for full matches of items in a list" {
  run str_contains "$(ls)" "Makefile"
  [ "$status" -eq 0 ]
}
@test "contains: returns 1 when no full matches" {
  run str_contains "$(ls)" "Make"
  [ "$status" -eq 1 ]
}

# == Get Field
@test "get_field: returns the field on a match" {
  result=$(str_get_field "foo bar bee" 2)
  [ "$result" = "bar" ]
}

# == Item Count
@test "item_count: returns 0 for empty strings" {
  result=$(str_item_count "")
  [ $result -eq 0 ]
}

@test "item_count: counts items in the same line" {
  result=$(str_item_count "foo bar bee")
  [ $result -eq 3 ]
}

@test "item_count: counts items across lines" {
  str=$(
    echo "one two three"
    echo "four five six"
  )
  result=$(str_item_count "$str")
  [ $result -eq 6 ]
}

# == matches
@test "matches: returns 0 for regex matches of items in a list" {
  run str_matches "$(ls)" "^Make"
  [ "$status" -eq 0 ]
}
@test "matches: returns 1 on pattern misses" {
  run str_matches "$(ls)" "^Make$"
  [ "$status" -eq 1 ]
}
@test "matches: recognizes extended patterns" {
  run str_matches "not a symlink: FOO" "not a symlink.+FOO$"
  [ "$status" -eq 0 ]
}
@test "matches: recognizes backslash patterns" {
  run str_matches "D  foo" '^\s?\w'
  [ "$status" -eq 0 ]
  run str_matches " D foo" "^\\s?\\w"
  [ "$status" -eq 0 ]
}

# == replace
@test "replace: replaces the matched pattern with the result" {
  result=$(str_replace "foobobaz" "o*b" "at")
  [ "$result" = "fatataz" ]
}

@test "replace: returns the input when the pattern does not match" {
  result=$(str_replace "foobar" "aa" "bb")
  [ "$result" = "foobar" ]
}
