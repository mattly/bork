#!/usr/bin/env bats

. test/helpers.sh
git () { . $BORK_SOURCE_DIR/core/git.sh $*; }

git_cmd_pointer=""
git_cmd_status=0
git_cmd_fetch=
git_fetch () {
  echo "." > $tmpdir/git_fetch
}
test_git () {
  if [ "$1" = "fetch" ]; then
    git_fetch
  else
    echo "$($git_cmd_pointer $*)"
    s=$?
    if [ "$git_cmd_pointer" = "command git" ]; then return $s
    else return $git_cmd_status
    fi
  fi
}
test_git_fetched () {
  fetched=$(cat "$tmpdir/git_fetch" | wc -l | awk '{print $1}')
  [ "$fetched" -eq 1 ]
}
set_test_pointer () { git_cmd_pointer=$1; }

setup () {
  baking_dir=
  p $BATS_TEST_DESCRIPTION
  command_git='test_git'
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
  test_git_fetched
}

git_repo_incorrect_branch () {
  echo "## foobar"
}
@test "src git status: returns 20 when not on the desired branch" {
  set_test_pointer 'git_repo_incorrect_branch'
  run git status git@github.com:mattly/bork
  [ "$status" -eq 20 ]
  test_git_fetched
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
  test_git_fetched
}

git_repo_has_unstaged_changes () {
  echo "## master"
  echo " D foo"
}
@test "src git status: returns 20 when the local git repository has unstaged changes" {
  set_test_pointer 'git_repo_has_unstaged_changes'
  run git status git@github.com:mattly/bork
  [ "$status" -eq 20 ]
  test_git_fetched
}

git_repo_has_uncommitted_changes () {
  echo "## master"
  echo "D  foo"
}
@test "src git status: returns 20 when local git repository has uncommitted staged changes" {
  set_test_pointer 'git_repo_has_uncommitted_changes'
  run git status git@github.com:mattly/bork
  [ "$status" -eq 20 ]
  test_git_fetched
}

git_repo_is_known_to_be_behind () {
  echo "## master..origin/master [behind 3]"
}
@test "src git status: returns 11 when the local git repository is known to be behind" {
  set_test_pointer 'git_repo_is_known_to_be_behind'
  run git status git@github.com:mattly/bork
  [ "$status" -eq 11 ]
  test_git_fetched
}

@test "src git status: returns 20 when the local repository is known to have diverged" {
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
  [ "$status" -eq 0 ]
  test_git_fetched
}

@test "src git install: bakes target dir, git clone" {
  url="git@github.com:mattly/bork"
  run git install $url
  [ "$status" -eq 0 ]
  run baked_output
  md="mkdir -p $tmpdir/bork"
  [ "${lines[0]}" = $md ]
  clone="test_git clone $url $tmpdir/bork"
  [ "${lines[1]}" = $clone ]
}

@test "src git upgrade: merges to new ref, echoes changelog" {
  run git upgrade "git@github.com:mattly/bork"
  [ "$status" -eq 0 ]
  run baked_output
  bake_dir="bake_in $tmpdir/bork"
  pull="test_git pull"
  display="test_git log HEAD@{1}.."
  [ "${lines[0]}" = $bake_dir ]
  [ "${lines[1]}" = $pull ]
  [ "${lines[2]}" = $display ]
}

