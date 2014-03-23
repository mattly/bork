#!/usr/bin/env bats

. test/helpers.sh

@test "pushes existing non-path values to \$used_types" {
  use brew git
  str_contains "$stdlib_types" "brew"
  str_contains "$stdlib_types" "git"
}

@test "returns 1 for non-valid values, does not add lib" {
  existing="$stdlib_types"
  status=$(use foo; echo $?)
}
