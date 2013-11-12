#!/usr/bin/env bats

. lib/functions-text.sh

@test "it returns 0 for empty strings" {
  result=$(str_item_count "")
  [ $result -eq 0 ]
}

@test "it counts items in the same line" {
  result=$(str_item_count "foo bar bee")
  [ $result -eq 3 ]
}

@test "it counts items across lines" {
  str=$(
    echo "one two three"
    echo "four five six"
  )
  result=$(str_item_count "$str")
  [ $result -eq 6 ]
}
