#!/usr/bin/env bats

. lib/destinations.sh

@test "it maintains a stack of destinations" {
  [ "$(destination)" = $PWD ]
  destination push $HOME
  [ "$(destination)" = $HOME ]
  destination push $PWD/.git
  [ "$(destination)" = "$PWD/.git" ]
  destination pop
  [ "$(destination)" = $HOME ]
  destination pop
  [ "$(destination)" = $PWD ]
  run destination foo
}
