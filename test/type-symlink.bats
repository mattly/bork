#!/usr/bin/env bats

. test/helpers.sh
symlink () { . $BORK_SOURCE_DIR/types/symlink.sh $*; }

# passes through to actual tests on the file system
baking_responder () { eval "$*"; }

tmpdir=
setup () {
  tmpdir=$(mktemp -d -t bork-symlinkXXXX)
  cd $tmpdir
  source=$(mktemp -d -t bork-symlink-srcXXXX)
  files=( 'LICENSE' 'README' )
  for f in ${files[@]}; do echo "$f" > $source/$f; done
}
teardown () {
  rm -rf $tmpdir
}

make_links () {
  for f in $source/*; do
    ln -sf $f $tmpdir/$(basename $f)
  done
}


@test "symlink: status returns OK if the source is symlinked in dest" {
  make_links
  run symlink status "$source/README"
  [ "$status" -eq $STATUS_OK ]
}

@test "symlink: status returns MISSING if the source is not symlinked in dest" {
  run symlink status "$source/README"
  [ "$status" -eq $STATUS_MISSING ]
}

@test "symlink: status returns MISMATCH_CLOBBER if dest is symlinked to a non-source" {
  ln -sf $source/README LICENSE
  run symlink status "$source/LICENSE"
  [ "$status" -eq $STATUS_MISMATCH_CLOBBER ]
  str_matches "${lines[0]}" "received source.+README$"
}

@test "symlink: status returns CONFLICT_CLOBBER if dest is a non-symlink" {
  echo "foo" > $tmpdir/LICENSE
  run symlink status "$source/LICENSE"
  [ "$status" -eq $STATUS_CONFLICT_CLOBBER ]
  str_matches "${lines[0]}" "not a symlink.+LICENSE$"
}

@test "symlink: status handles --tmpl argument when missing" {
  make_links
  run symlink status "$source/README" --tmpl='.$f'
  [ "$status" -eq $STATUS_MISSING ]
}
@test "symlink: status handles --tmpl argument when present" {
  ln -s "$source/LICENSE" "$tmpdir/.LICENSE"
  run symlink status "$source/LICENSE" --tmpl='.$f'
  [ "$status" -eq $STATUS_OK ]
}

@test "symlink: install creates the target symlink" {
  run symlink install "$source/README"
  [ "$status" -eq 0 ]
  run baked_output
  [ "ln -s $source/README README" = ${lines[0]} ]
  [ -h README ]
  [ "$source/README" = $(readlink README) ]
}

@test "symlink: install bakes using --tmpl" {
  run symlink install "$source/README" --tmpl='.$f'
  [ "$status" -eq 0 ]
  run baked_output
  [ "ln -s $source/README .README" = ${lines[0]} ]
  [ -h .README ]
  [ "$source/README" = $(readlink .README) ]
}

