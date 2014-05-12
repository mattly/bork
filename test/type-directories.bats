#!/usr/bin/env bats

. test/helpers.sh
directories () { . $BORK_SOURCE_DIR/types/directories.sh $*; }

# these tests use live directories in a tempdir
baking_responder () { eval "$*"; }

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

@test "directories: status returns OK if all directories are present" {
  mkdirs foo bar
  run directories status foo bar
  [ "$status" -eq $STATUS_OK ]
}

@test "directories: status returns MISSING if no directories are present" {
  run directories status foo bar
  [ "$status" -eq $STATUS_MISSING ]
}

@test "directories: status returns PARTIAL if some directories are present" {
  mkdirs bar bee
  run directories status foo bar
  [ "$status" -eq $STATUS_PARTIAL ]
}

@test "directories: status returns CONFLICT_UPGRADE if any targets are non-directories" {
  echo "FOO" > foo
  echo "BAZ" > baz
  mkdirs bee
  run directories status bee bar foo baz
  [ "$status" -eq $STATUS_CONFLICT_UPGRADE ]
  str_matches "${lines[0]}" "exists.*foo"
  str_matches "${lines[1]}" "exists.*baz"
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
