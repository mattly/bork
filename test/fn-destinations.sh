#!/usr/bin/env bats

. test/helpers.sh

@test "it maintains a stack of destinations" {
  [ "$(destination)" = $PWD ]
  [ "$(destination size)" -eq 0 ]
  destination push $HOME
  [ "$(destination)" = $HOME ]
  [ "$(destination size)" -eq 1 ]
  destination push $PWD/.git
  [ "$(destination)" = "$PWD/.git" ]
  [ "$(destination size)" -eq 2 ]
  destination pop
  [ "$(destination)" = $HOME ]
  [ "$(destination size)" -eq 1 ]
  destination pop
  [ "$(destination)" = $PWD ]
  [ "$(destination size)" -eq 0 ]
  destination push $HOME
  [ "$(destination size)" -eq 1 ]
  destination clear
  [ "$(destination size)" -eq 0 ]
}

@test "it returns 1 on unknown command" {
  run destination foo
  [ "$status" -eq 1 ]
}

@test "pop returns 1 on empty stack" {
  run destination pop
  [ "$status" -eq 1 ]
}
