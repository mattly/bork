#!/usr/bin/env bats

. test/helpers.sh
brew () { . $BORK_SOURCE_DIR/types/brew.sh $*; }

setup () {
  respond_to "uname -s" "echo Darwin"
  respond_to "brew list" "cat $fixtures/brew-list.txt"
  respond_to "brew outdated" "cat $fixtures/brew-outdated.txt"
}

@test "brew status reports unsupported platform" {
  respond_to "uname -s" "echo Linux"
  run brew status something
  [ "$status" -eq $STATUS_UNSUPPORTED_PLATFORM ]
}

@test "brew status reports missing brew exec" {
  respond_to "which brew" "return 1"
  run brew status something
  [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}

@test "brew status reports a package is missing" {
  run brew status missing_package_is_missing
  [ "$status" -eq $STATUS_MISSING ]
}

@test "brew status reports a package is outdated" {
  run brew status outdated_package
  [ "$status" -eq $STATUS_OUTDATED ]
}

@test "brew status reports a packge is current" {
  run brew status current_package
  [ "$status" -eq $STATUS_OK ]
  [ "${#lines[*]}" -eq 0 ]
}

@test "brew install runs 'install'" {
  run brew install missing_package_is_missing
  [ "$status" -eq 0 ]
  run baked_output
  [ "$output" = 'brew install missing_package_is_missing' ]
}

@test "brew upgrade runs 'upgrade'" {
  run brew upgrade outdated_package
  [ "$status" -eq 0 ]
  run baked_output
  [ "$output" = 'brew upgrade outdated_package' ]
}

