#!/usr/bin/env bats

. test/helpers.sh
functionize_thing sources/symlink.sh

tmpdir=
setup () {
  source=$PWD
  tmpdir=$(mktemp -d -t bork-symlink)
  cd $tmpdir
  for f in $source/*; do
    ln -sf $f $tmpdir/$(basename $f)
  done
}
teardown () {
  rm -rf $tmpdir
}


@test "symlink: status returns 0 if all sources are symlinked in dest" {
  run symlink status "$source/*"
  [ "$status" -eq 0 ]
}

@test "symlink: status returns 10 if no sources are symlinked in dest" {
  rm -rf $tmpdir
  mkdir $tmpdir
  run symlink status "$source/*"
  [ "$status" -eq 10 ]
}

@test "symlink: status returns 11 if some sources are symlinked in dest" {
  rm $tmpdir/LICENSE
  run symlink status "$source/*"
  [ "$status" -eq 11 ]
}

@test "symlink: status returns 20 if any dest is symlinked to a non-source" {
  rm $tmpdir/LICENSE
  ln -sf $source/README.md $tmpdir/LICENSE
  run symlink status "$source/*"
  [ "$status" -eq 20 ]
}
@test "symlink: status returns 20 if any dest is a non-symlink" {
  rm $tmpdir/LICENSE
  echo "foo" > $tmpdir/LICENSE
  run symlink status "$source/*"
  [ "$status" -eq 20 ]
}

