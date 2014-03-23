#!/usr/bin/env bats

. test/helpers.sh

@test "use pushes existing non-path values to \$stdlib_types" {
  use brew apt git
  str_contains "$stdlib_types" "brew"
  str_contains "$stdlib_types" "apt"
  str_contains "$stdlib_types" "git"
}

@test "use returns 1 for non-valid values, does not add lib" {
  existing="$stdlib_types"
  status=$(use foo; echo $?)
}
