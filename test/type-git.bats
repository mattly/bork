#!/usr/bin/env bats

. test/helpers.sh
git () { . $BORK_SOURCE_DIR/types/git.sh $*; }

repo="git@github.com:mattly/bork"
dir_exists=1
dir_listing=$(echo 'foo'; echo 'bar')
git_status=
setup () {
  respond_to "[ ! -d bork ]"           "dir_exists_handler"
  respond_to "ls -A bork"              "dir_listing_handler"
  respond_to "git status -uno -b --porcelain" "git_status_handler"
}
dir_exists_handler ()   { [ "$dir_exists" -eq 0 ]; }
dir_listing_handler ()  { echo "$dir_listing"; }
git_status_handler ()   { echo "$git_status"; }

@test "git status: returns FAILED_PRECONDITION when git exec is missing" {
  respond_to "which git" "return 1"
  run git status $repo
  [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}

@test "src git status: returns MISSING when the directory doesn't exist" {
  dir_exists=0
  run git status $repo
  [ "$status" -eq $STATUS_MISSING ]
}

@test "src git status: returns MISSING when the directory is empty" {
  dir_listing=''
  run git status $repo
  [ "$status" -eq $STATUS_MISSING ]
}

@test "src git status: returns CONFLICT_CLOBBER when the directory is not empty and not a git repository" {
  respond_to "git fetch" "return_with 1"
  run git status $repo
  [ "$status" -eq $STATUS_CONFLICT_CLOBBER ]
  echo "$output" | grep -E "bork exists"
}

@test "src git status: returns MISMATCH_UPGRADE when not on the desired branch" {
  git_status="## foobar"
  run git status $repo
  [ "$status" -eq $STATUS_MISMATCH_UPGRADE ]
  echo "$output" | grep -E 'incorrect branch'
}

@test "src git status: returns MISMATCH_UPGRADE when the local git repository uses another origin" {
  skip
}

@test "src git status: returns CONFLICT_UPGRADE when the local git repository is ahead" {
  git_status="## master..origin/master [ahead 3]"
  run git status $repo
  [ "$status" -eq $STATUS_CONFLICT_UPGRADE ]
  echo "$output" | grep -E 'is ahead'
}

@test "src git status: returns CONFLICT_UPGRADE when the local git repository has unstaged changes" {
  git_status=$(echo "## master"; echo " D foo")
  run git status git@github.com:mattly/bork
  [ "$status" -eq $STATUS_CONFLICT_UPGRADE ]
  echo "$output" | grep -E 'uncommitted'
}

@test "src git status: returns CONFLICT_UPGRADE when local git repository has uncommitted staged changes" {
  git_status=$(echo "## master"; echo "D  foo")
  run git status git@github.com:mattly/bork
  [ "$status" -eq $STATUS_CONFLICT_UPGRADE ]
  echo "$output" | grep -E 'uncommitted'
}

@test "src git status: returns OUTDATED when the local git repository is known to be behind" {
  git_status="## master..origin/master [behind 3]"
  run git status git@github.com:mattly/bork
  [ "$status" -eq $STATUS_OUTDATED ]
}

@test "src git status: returns OK when the git repository is up-to-date" {
  git_status="## master"
  run git status git@github.com:mattly/bork
  [ "$status" -eq $STATUS_OK ]
}

@test "src git install: bakes target dir, git clone" {
  run git install $repo
  [ "$status" -eq 0 ]
  run baked_output
  [ "mkdir -p bork" = ${lines[0]} ]
  [ "git clone $repo bork" = ${lines[1]} ]
}

@test "src git upgrade: merges to new ref, echoes changelog" {
  run git upgrade $repo
  [ "$status" -eq 0 ]
  run baked_output
  [ "cd bork" = ${lines[0]} ]
  [ "git pull" = ${lines[1]} ]
  [ "git checkout master" = ${lines[2]} ]
  [ "git log HEAD@{2}.." = ${lines[3]} ]
}

