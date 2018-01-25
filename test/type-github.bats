#!/usr/bin/env bats

. test/helpers.sh
. bin/bork-compile > /dev/null
github () { . $BORK_SOURCE_DIR/types/github.sh $*; }

intercept_git () { echo "$*"; }
git_call="intercept_git"

@test "github status: handles implicit target" {
  run github status mattly/bork
  [ "$output" = "status https://github.com/mattly/bork.git" ]
}

@test "github status: handles explicit target" {
  run github status /Users/mattly/code/bork mattly/bork
  [ "$output" = "status /Users/mattly/code/bork https://github.com/mattly/bork.git" ]
}

@test "github status: handles --ssh argument" {
  run github status mattly/bork --ssh
  [ "$output" = "status git@github.com:mattly/bork.git" ]
}

@test "github compile: outputs git type via include_assertion" {
  operation="compile"
  gitfn=$(include_assertion git $BORK_SOURCE_DIR/types/git.sh)
  bag init compiled_types
  run github compile foo/bar
  [ "$status" -eq 0 ]
  [[ ${output} == "${gitfn}" ]]
}
