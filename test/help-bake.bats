#!/usr/bin/env bats

. test/helpers.sh

@test "bake will escape its arguments before eval" {
  run bake ls -la "foo bar"
  run baked_output
  [ "$output" = " 'ls' '-la' 'foo bar'" ]
}
