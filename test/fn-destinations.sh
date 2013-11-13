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
}

@test "it returns 1 on unknown command" {
  run destination foo
  [ "$status" -eq 1 ]
}

@test "pop returns 1 on empty stack" {
  run destination pop
  [ "$status" -eq 1 ]
}
