#!/usr/bin/env bats

. lib/destinations.sh

@test "it maintains a stack of destinations" {
  [ "$(destination)" = $PWD ]
  destination_push $HOME
  [ "$(destination)" = $HOME ]
  destination_push $PWD/.git
  [ "$(destination)" = "$PWD/.git" ]
  destination_pop
  [ "$(destination)" = $HOME ]
  destination_pop
  [ "$(destination)" = $PWD ]
}
