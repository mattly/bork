#!/usr/bin/env bats

. test/helpers.sh

cwd=
setup () {
  cwd=$PWD
}

@test "it maintains a stack of destinations" {
  [ "$(destination)" = $cwd ]
  [ "$(destination size)" -eq 0 ]

  destination push $HOME
  [ "$(destination)" = $HOME ]
  [ $PWD = $HOME ]
  [ "$(destination size)" -eq 1 ]

  destination push $cwd/.git
  [ "$(destination)" = "$cwd/.git" ]
  [ $PWD = "$cwd/.git" ]
  [ "$(destination size)" -eq 2 ]

  destination pop
  [ "$(destination)" = $HOME ]
  [ $PWD = $HOME ]
  [ "$(destination size)" -eq 1 ]

  destination pop
  [ "$(destination)" = $cwd ]
  [ $PWD = "$cwd" ]
  [ "$(destination size)" -eq 0 ]

  destination push $HOME
  [ "$(destination size)" -eq 1 ]

  destination clear
  [ "$(destination size)" -eq 0 ]
  [ "$PWD" = "$cwd" ]
}

@test "it returns 1 on unknown command" {
  run destination foo
  [ "$status" -eq 1 ]
}

@test "pop returns 1 on empty stack" {
  run destination pop
  [ "$status" -eq 1 ]
}
