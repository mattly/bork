#!/usr/bin/env bats

. test/helpers.sh

cwd=
setup () {
  cwd=$PWD
}

@test "destinations maintains a stack of locations" {
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

@test "destinations returns 1 on unknown command" {
  run destination foo
  [ "$status" -eq 1 ]
}

