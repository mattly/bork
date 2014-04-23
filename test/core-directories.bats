#!/usr/bin/env bats

. test/helpers.sh
directories () { . $BORK_SOURCE_DIR/core/directories.sh $*; }

# these tests use live directories in a tempdir
dir_responder () { eval "$*"; }
baking_responder='dir_responder'

setup () {
  tmpdir=$(mktemp -d -t bork-dir)
  cd $tmpdir
}
teardown () {
  rm -rf $tmpdir
}

mkdirs () {
  for d in $*; do mkdir -p $d; done
}

@test "directories: status returns 0 if all directories are present" {
  mkdirs foo bar
  run directories status foo bar
  [ "$status" -eq 0 ]
}

@test "directories: status returns 10 if no directories are present" {
  run directories status foo bar
  [ "$status" -eq 10 ]
}

@test "directories: status returns 11 if some directories are present" {
  mkdirs bar bee
  run directories status foo bar
  [ "$status" -eq 11 ]
}

@test "directories: status returns 20 if any targets are non-directories" {
  echo "FOO" > foo
  mkdirs bee
  run directories status bee bar foo
  [ "$status" -eq 20 ]
}

@test "directories: install creates all target directories" {
  run directories install foo bar bee
  [ "$status" -eq 0 ]
  run baked_output
  [ "${lines[1]}" = "mkdir -p foo" ]
  [ "${lines[3]}" = "mkdir -p bar" ]
  [ "${lines[5]}" = "mkdir -p bee" ]
}

@test "directories: upgrade creates all missing target directories" {
  mkdirs foo
  run directories upgrade foo bar bee
  [ "$status" -eq 0 ]
  run baked_output
  [ "${lines[2]}" = "mkdir -p bar" ]
  [ "${lines[4]}" = "mkdir -p bee" ]
}
