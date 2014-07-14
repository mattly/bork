#!/usr/bin/env bats

. test/helpers.sh
. bin/bork-compile > /dev/null
github () { . $BORK_SOURCE_DIR/types/github.sh $*; }

@test "github compile: outputs git type via include_assertion" {
  operation="compile"
  git=$(include_assertion git $BORK_SOURCE_DIR/types/git.sh)
  bag init compiled_types
  run github compile foo/bar
  [ "$status" -eq 0 ]
  n=0
  for line in $git; do
    p "expected: $line"
    p "received: ${lines[n]}"
    [ "${lines[n]}" = $line ]
    n=$(( n + 1 ))
  done
}
