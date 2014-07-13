#!/usr/bin/env bats

. test/helpers.sh

compiled_type_push () {
  echo $1 >> $compiled_type_test
}
compiled_type_exists () {
  [ "$1" = "aloha" ] && return 0 || return 1
}

setup () {
  example_include="$BORK_SCRIPT_DIR/core/git.sh"
  compiled_type_test=$(mktemp -t cttXXXXXX)
}

@test "is_compiling: returns 1 if not compiling" {
  run is_compiling
  [ "$status" -eq 1 ]
}
@test "is_compiling: returns 0 if compiling" {
  operation="compile"
  run is_compiling
  [ "$status" -eq 0 ]
}

@test "include_assertion: does nothing if not compiling" {
  run include_assertion 'hello' "$example_include"
  [ "$status" -eq 0 ]
}

@test "include_assertion: outputs function if compiling" {
  operation="compile"
  run include_assertion 'hello' "$example_include"
  [ "$status" -eq 0 ]
  git_length=$(cat $example_include | grep -E '\S+' | wc -l | awk '{print $1}')
  (( git_length = $git_length + 3 ))
  [ "${#lines[*]}" -eq $git_length ]
  comment_leader="# $example_include"
  [ "${lines[0]}" = $comment_leader ]
  [ "${lines[1]}" = "type_hello () {" ]
  [ "${lines[2]}" = $(cat $example_include | head -n 1) ]
  run cat $compiled_type_test
  [ "${#lines[*]}" -eq 1 ]
  [ "${lines[0]}" = "hello" ]
}

@test "include_assertion: does nothing if fn compiled already" {
  operation="compile"
  run include_assertion 'aloha' "$example_include"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  run cat $compiled_type_test
  [ -z "$output" ]
}
