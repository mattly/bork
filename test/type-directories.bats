#!/usr/bin/env bats

. test/helpers.sh
directory () { . $BORK_SOURCE_DIR/types/directory.sh $*; }

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

@test "directory: status returns OK if directory is present" {
  mkdirs foo
  run directory status foo
  [ "$status" -eq $STATUS_OK ]
}

@test "directory: status returns MISSING if directory isn't present" {
  run directory status foo
  [ "$status" -eq $STATUS_MISSING ]
}

@test "directory: status returns CONFLICT_CLOBBER if target is non-directory" {
  echo "FOO" > foo
  run directory status foo
  [ "$status" -eq $STATUS_CONFLICT_CLOBBER ]
  str_matches "${lines[0]}" "exists"
}

@test "directory: install creates target directory" {
  run directory install foo
  [ "$status" -eq 0 ]
  run baked_output
  [ "${lines[0]}" = "mkdir -p foo" ]
}

