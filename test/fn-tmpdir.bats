#!/usr/bin/env bats

. test/helpers.sh

cwd=
setup () {
  cwd=$PWD
}

@test "use_tmpdir sets variable, pushes destination" {
  use_tmpdir
  [ "$(destination)" = $PWD ]
  [ "$bork_using_tmpdir" = $PWD ]
}

@test "use_tmpdir only uses one at a time" {
  use_tmpdir
  run use_tmpdir
  [ "$status" -eq 1 ]
}

@test "clean_tmpdir unsets variable, pops dest, removes dir" {
  tmpdir=$(mktemp -d -t "tmpdir-test")
  [ -d $tmpdir ]
  bork_using_tmpdir=$tmpdir
  [ "$(destination)" = $cwd ]
  destination push $bork_using_tmpdir

  clean_tmpdir
  [ "$(destination)" = $cwd ]
  [ "$(PWD)" = $cwd ]
  [ -z "$bork_using_tmpdir" ]
  [ ! -e $tmpdir ]
}

