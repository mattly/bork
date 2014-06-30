#!/usr/bin/env bats

. test/helpers.sh

@test "destination sets the \$BORK_DESTINATION" {
  destination /usr/local/bin
  [ "$?" -eq 0 ]
  [ "$BORK_DESTINATION" = '/usr/local/bin' ]
}

@test "destination echoes warning, returns 1 if destination doesn't exist" {
  run destination missing_dir
  [ "$status" -eq 1 ]
  echo "$output" | grep -e 'missing_dir'
}
