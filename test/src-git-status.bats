#!/usr/bin/env bats

. test/helpers.sh

functionize_thing "sources/git.sh"

git_cmd_pointer=""
git_cmd_status=0
test_git () {
  out=$($git_cmd_pointer $*)
  s=$?
  echo "$out"
  p "$git_cmd_pointer: $s $out"
  if [ "$git_cmd_pointer" = "command git" ]; then return $s
  else return $git_cmd_status
  fi
}
set_test_pointer () { git_cmd_pointer=$1; }

setup () {
  p "$BATS_TEST_DESCRIPTION"
  operation=status
  git_cmd_pointer="command git"
  git_cmd_status=0
  tmpdir=$(mktemp -d -t "git-status-test")
  destination push $tmpdir
  target_dir=$tmpdir/bork
  mkdir -p $target_dir
  pushd $target_dir
  echo "." > foo
}

teardown () {
  run rm -rf $tmpdir
  destination clear
}

@test "returns 10 when the directory doesn't exist" {
  rm -rf $target_dir
  [ ! -d $target_dir ]
  run git git@github.com:mattly/bork
  [ "$status" -eq 10 ]
}

@test "returns 10 when the directory is empty" {
  rm -rf $target_dir/*
  [ $(str_item_count "$(ls $target_dir)") -eq 0 ]
  run git git@github.com:mattly/bork
  [ "$status" -eq 10 ]
}

@test "returns 20 when the directory is not empty and not a git repository" {
  run git git@github.com:mattly/bork
  [ "$status" -eq 20 ]
}

git_repo_incorrect_branch () {
  echo "## foobar"
}
@test "returns 20 when not on the desired branch" {
  set_test_pointer 'git_repo_incorrect_branch'
  run git git@github.com:mattly/bork
  [ "$status" -eq 20 ]
}

@test "returns 20 when the local git repository uses another origin" {
  skip
}

git_repo_is_ahead () {
  echo "## master..origin/master [ahead 3]"
}
@test "returns 20 when the local git repository is ahead" {
  set_test_pointer 'git_repo_is_ahead'
  run git git@github.com:mattly/bork
  [ "$status" -eq 20 ]
}

git_repo_has_unstaged_changes () {
  echo "## master"
  echo " D foo"
}
@test "returns 20 when the local git repository has unstaged changes" {
  set_test_pointer 'git_repo_has_unstaged_changes'
  run git git@github.com:mattly/bork
  [ "$status" -eq 20 ]
}

git_repo_has_uncommitted_changes () {
  echo "## master"
  echo "D  foo"
}
@test "returns 20 when local git repository has uncommitted staged changes" {
  set_test_pointer 'git_repo_has_uncommitted_changes'
  run git git@github.com:mattly/bork
  [ "$status" -eq 20 ]
}

git_repo_is_known_to_be_behind () {
  echo "## master..origin/master [behind 3]"
}
@test "returns 11 when the local git repository is known to be behind" {
  set_test_pointer 'git_repo_is_known_to_be_behind'
  run git git@github.com:mattly/bork
  [ "$status" -eq 11 ]
}

@test "returns 20 when the local repository is known to have diverged" {
skip
}
@test "returns 11 when after fetching, the local git repository is behind" {
skip
}
@test "returns 20 when after fetching, the local repository has diverged" {
skip
}

git_repo_is_fine () {
  echo "## master"
}
@test "returns 0 when the git repository is up-to-date" {
  set_test_pointer 'git_repo_is_fine'
  run git git@github.com:mattly/bork
  p "$status"
  [ "$status" -eq 0 ]
}

