#!/usr/bin/env bats

for f in $(ls lib/*.sh); do . $f; done
. test/helpers.sh

functionize_thing "sources/git.sh"

setup () {
  operation=status
  tmpdir=$(mktemp -d -t "git-status-test")
  destination push $tmpdir
  target_dir=$tmpdir/bork
  mkdir -p $target_dir
  pushd $target_dir
}

teardown () {
  run rm -rf $target_dir
  destination clear
}

setup_git_repo () {
  command git init .
  echo "foo" > $target_dir/file
  command git add *
  command git commit -m "fix"
  command git remote add origin git@github.com:mattly/bork
}

@test "status: returns 10 when the directory doesn't exist" {
  rmdir $target_dir
  [ ! -d $target_dir ]
  run git git@github.com:mattly/bork
  [ "$status" -eq 10 ]
}
@test "status: returns 10 when the directory is empty" {
  [ $(str_item_count "$(ls $target_dir)") -eq 0 ]
  run git git@github.com:mattly/bork
  [ "$status" -eq 10 ]
}
@test "status: returns 20 when the directory is not empty and not a git repository" {
  echo "foo" > $target_dir/file
  run git git@github.com:mattly/bork
  [ "$status" -eq 20 ]
}
@test "status: returns 20 when the local git repository uses another origin" {
  skip
}
@test "status: returns 20 when the local git repository is ahead" {
  setup_git_repo
  run git git@github.com:mattly/bork
  [ "$status" -eq 20 ]
}
@test "status: returns 20 when the local git repository has uncommitted changes" {
  setup_git_repo
  run git@github.com:mattly/bork
  [ "$status" -eq 20 ]
}
@test "status: returns 11 when the local git repository is known to be behind" {
skip
}
@test "status: returns 11 when after fetching, the local git repository is behind" {
skip
}
@test "status: returns 0 when the git repository is up-to-date" {
skip
}

