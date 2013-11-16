#!/usr/bin/env bats

. test/helpers.sh

functionize_thing "sources/git.sh"

git_cmd_pointer=""
git_cmd_status=0
test_git () {
  echo "$($git_cmd_pointer $*)"
  s=$?
  if [ "$git_cmd_pointer" = "command git" ]; then return $s
  else return $git_cmd_status
  fi
}
set_test_pointer () { git_cmd_pointer=$1; }

setup () {
  p $BATS_TEST_DESCRIPTION
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

@test "src git status: returns 10 when the directory doesn't exist" {
  rm -rf $target_dir
  [ ! -d $target_dir ]
  run git status git@github.com:mattly/bork
  [ "$status" -eq 10 ]
}

@test "src git status: returns 10 when the directory is empty" {
  rm -rf $target_dir/*
  [ $(str_item_count "$(ls $target_dir)") -eq 0 ]
  run git status git@github.com:mattly/bork
  [ "$status" -eq 10 ]
}

@test "src git status: returns 20 when the directory is not empty and not a git repository" {
  run git status git@github.com:mattly/bork
  [ "$status" -eq 20 ]
}

git_repo_incorrect_branch () {
  echo "## foobar"
}
@test "src git status: returns 20 when not on the desired branch" {
  set_test_pointer 'git_repo_incorrect_branch'
  run git status git@github.com:mattly/bork
  [ "$status" -eq 20 ]
}

@test "src git status: returns 20 when the local git repository uses another origin" {
  skip
}

git_repo_is_ahead () {
  echo "## master..origin/master [ahead 3]"
}
@test "src git status: returns 20 when the local git repository is ahead" {
  set_test_pointer 'git_repo_is_ahead'
  run git status git@github.com:mattly/bork
  [ "$status" -eq 20 ]
}

git_repo_has_unstaged_changes () {
  echo "## master"
  echo " D foo"
}
@test "src git status: returns 20 when the local git repository has unstaged changes" {
  set_test_pointer 'git_repo_has_unstaged_changes'
  run git status git@github.com:mattly/bork
  [ "$status" -eq 20 ]
}

git_repo_has_uncommitted_changes () {
  echo "## master"
  echo "D  foo"
}
@test "src git status: returns 20 when local git repository has uncommitted staged changes" {
  set_test_pointer 'git_repo_has_uncommitted_changes'
  run git status git@github.com:mattly/bork
  [ "$status" -eq 20 ]
}

git_repo_is_known_to_be_behind () {
  echo "## master..origin/master [behind 3]"
}
@test "src git status: returns 11 when the local git repository is known to be behind" {
  set_test_pointer 'git_repo_is_known_to_be_behind'
  run git status git@github.com:mattly/bork
  [ "$status" -eq 11 ]
}

@test "src git status: returns 20 when the local repository is known to have diverged" {
skip
}
@test "src git status: returns 11 when after fetching, the local git repository is behind" {
skip
}
@test "src git status: returns 20 when after fetching, the local repository has diverged" {
skip
}

git_repo_is_fine () {
  echo "## master"
}
@test "src git status: returns 0 when the git repository is up-to-date" {
  set_test_pointer 'git_repo_is_fine'
  run git status git@github.com:mattly/bork
  p "$status"
  [ "$status" -eq 0 ]
}

