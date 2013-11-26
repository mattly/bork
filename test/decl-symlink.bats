#!/usr/bin/env bats

. test/helpers.sh
functionize_thing declarations/symlink.sh

tmpdir=
setup () {
  tmpdir=$(mktemp -d -t bork-symlink)
  cd $tmpdir
  source=$(mktemp -d -t bork-symlink-src)
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


@test "symlink: status returns 0 if all sources are symlinked in dest" {
  make_links
  run symlink status "$source/*"
  [ "$status" -eq 0 ]
}

@test "symlink: status returns 10 if no sources are symlinked in dest" {
  run symlink status "$source/*"
  [ "$status" -eq 10 ]
}

@test "symlink: status returns 11 if some sources are symlinked in dest" {
  make_links
  rm $tmpdir/LICENSE
  run symlink status "$source/*"
  [ "$status" -eq 11 ]
}

@test "symlink: status returns 20 if any dest is symlinked to a non-source" {
  ln -sf $source/README $tmpdir/LICENSE
  run symlink status "$source/*"
  [ "$status" -eq 20 ]
}
@test "symlink: status returns 20 if any dest is a non-symlink" {
  echo "foo" > $tmpdir/LICENSE
  run symlink status "$source/*"
  [ "$status" -eq 20 ]
}

@test "symlink: status handles --tmpl argument" {
  make_links
  run symlink status "$source/*" --tmpl=".\$f"
  [ "$status" -eq 10 ]
  ln -s "$source/LICENSE" "$tmpdir/.LICENSE"
  run symlink status "$source/*" --tmpl=".\$f"
  [ "$status" -eq 11 ]
}

@test "symlink: status handles a --dest argument" {
  make_links
  cd $(mktemp -d -t bork_sym_2)
  run symlink status "$source/*" --dest=$tmpdir
  [ "$status" -eq 0 ]
}

@test "symlink: install creates all target files" {
  run symlink install "$source/*"
  [ "$status" -eq 0 ]
  run baked_output
  accum=0
  while [ "$accum" -lt ${#files[@]} ]; do
    fname=${files[accum]}
    baked_cmd="ln -s $source/$fname $fname"
    [ "${lines[accum]}" = $baked_cmd ]
    (( accum++ ))
  done
}

@test "symlink: upgrade creates missing target files" {
  ln -s $source/README $tmpdir/README
  run symlink upgrade "$source/*"
  [ "$status" -eq 0 ]
  run baked_output
  [ "${#lines[@]}" -eq 1 ]
  bake_cmd="ln -s $source/LICENSE LICENSE"
  [ "${lines[0]}" = $bake_cmd ]
}

@test "symlink: install bakes using --tmpl" {
  run symlink install "$source/*" --tmpl=".\$f"
  [ "$status" -eq 0 ]
  run baked_output
  while [ "$accum" -l ${#files[@]} ]; do
    fname=${files[accum]}
    baked_cmd="ln -s $source/$fname .$fname"
    [ "${lines[accum]}" = $baked_cmd ]
    (( accum++ ))
  done
}

@test "symlink: install handles a --dest argument" {
  cd $(mktemp -d -t bork_sym2)
  run symlink install "$source/*" --dest=$tmpdir
  [ "$status" -eq 0 ]
  run baked_output
  while [ "$accum" -l ${#files[@]} ]; do
    fname=${files[accum]}
    baked_cmd="ln -s $source/$fname .$fname"
    [ "${lines[accum]}" = $baked_cmd ]
    (( accum++ ))
  done
}
