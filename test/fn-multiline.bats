#!/usr/bin/env bats

. test/helpers.sh

@test "multiline: init sets the variable" {
  foo="foo"
  multiline init 'foo'
  [ -z "$foo" ]
}

@test "multiline: add adds to the variable" {
  foo="foo"
  foo=$(multiline add 'foo' 'bar')
  run echo "$foo"
  [ "${#lines[*]}" -eq 2 ]
  [ "${lines[0]}" = "foo" ]
  [ "${lines[1]}" = "bar" ]
}

@test "multiline: find echoes the first match on match" {
  foo=$(echo "foo=foo"; echo "bar=bee"; echo "bar=boo" )
  run echo "$foo"
  [ "${#lines[*]}" -eq 3 ]
  run multiline find 'foo' '^bar='
  [ "$status" -eq 0 ]
  [ "$output" = "bar=bee" ]
}

@test "multiline: find returns 1 on miss" {
  foo=$(echo "foo=foo")
  run multiline find 'foo' '^bar'
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "multiline: key echoes value of first match" {
  foo=$(echo "foo=foo"; echo "bar=bee"; echo "bar=boo")
  run echo "$foo"
  [ "${#lines[*]}" -eq 3 ]
  run multiline key 'foo' 'bar'
  [ "$status" -eq 0 ]
  [ "$output" = "bee" ]
}

@test "multiline: key returns 1 on miss" {
  foo=$(echo "foo=foo")
  run multiline key 'foo' 'bar'
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

