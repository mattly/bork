#!/usr/bin/env bats

. test/helpers.sh

@test "bag: init creates variable" {
  bag init foo
  foo[0]="hello"
  [ "${#foo[*]}" -eq 1 ]
}

@test "bag: init clears existing variable" {
  foo=( one two three )
  [ "${foo[0]}" = "one" ]
  bag init foo
  [ "${#foo[*]}" -eq 0 ]
}

@test "bag: push appends to stack" {
  bag init foo
  bag push foo "something else"
  bag push foo "algo mas"
  [ "${#foo[*]}" -eq 2 ]
  [ "${foo[0]}" = "something else" ]
  [ "${foo[1]}" = "algo mas" ]
}

@test "bag: read echoes the read item" {
  bag init foo
  bag push foo "something"
  [ "$(bag read foo)" = "something" ]
  bag push foo "algo mas"
  [ "$(bag read foo)" = "algo mas" ]
}

@test "bag: pop removes top item from stack" {
  bag init foo
  bag push foo "something"
  bag push foo "algo mas"
  [ "${#foo[*]}" -eq 2 ]
  bag pop foo
  [ "${#foo[*]}" -eq 1 ]
}

@test "bag: set appends key/value to stack" {
  bag init foo
  bag push foo "something"
  bag set foo something else
  bag set foo algo mas
  [ "${#foo[*]}" -eq 3 ]
  [ "${foo[1]}" = "something=else" ]
  [ "${foo[2]}" = "algo=mas" ]
}

@test "bag: set overwrites an existing key" {
  bag init foo
  bag set foo something else
  bag set foo algo mas
  bag set foo something more
  [ "${#foo[*]}" -eq 2 ]
  val=$(bag get foo something)
  [ "$val" = "more" ]
}

@test "bag: get returns a specified key" {
  bag init foo
  bag set foo something else
  bag set foo algo mas
  val=$(bag get foo something)
  [ "$val" = "else" ]
}

@test "bag: filter echoes all lines matching a pattern" {
  bag init foo
  bag push foo something
  bag set foo something else
  bag set foo algo mas
  bag push foo "something in the way she moves me"
  bag push foo "it's about the something"
  results=$(bag filter foo '^something')
  run echo "$results"
  [ "${#lines[*]}" -eq 3 ]
  [ "${lines[0]}" = "something" ]
  [ "${lines[1]}" = "something=else" ]
  [ "${lines[2]}" = "something in the way she moves me" ]
}

@test "bag: index echoes index of first matching item" {
  bag init foo
  bag push foo something
  bag push foo "algo mas"
  bag push foo "something=more"
  [ "$(bag index foo '^something')" -eq 0 ]
  [ "$(bag index foo 'more$')" -eq 2 ]
}

@test "bag: find echoes first line matching a pattern" {
  bag init foo
  bag push foo something
  bag push foo "algo mas"
  bag push foo "something in the way she moes me"
  result=$(bag find foo '^something')
  run echo "$result"
  [ "${#lines[*]}" -eq 1 ]
  [ "${lines[0]}" = "something" ]
}

@test "bag: print echoes each item line-by-line" {
  bag init foo
  bag push foo "{"
  bag push foo "  key = value"
  bag push foo "}"
  run bag print foo
  [ "${#lines[*]}" -eq 3 ]
  [ "${lines[0]}" = "{" ]
  [ "${lines[1]}" = "  key = value" ]
  [ "${lines[2]}" = "}" ]
}
