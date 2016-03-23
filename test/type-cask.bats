#!/usr/bin/env bats

. test/helpers.sh
cask () { . $BORK_SOURCE_DIR/types/cask.sh $*; }

setup () {
  respond_to "uname -s" "echo Darwin"
  respond_to "which brew" "echo /usr/local/bin/brew"
  respond_to "brew cask list" "cat $fixtures/cask-list.txt"
}

@test "cask statups reports unsupported platforms" {
  respond_to "uname -s" "echo Linux"
  run cask status something
  [ "$status" -eq $STATUS_UNSUPPORTED_PLATFORM ]
}

@test "cask status reports missing brew exec" {
  respond_to "which brew" "return 1"
  run cask status something
  [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}

@test "cask status reports missing cask package" {
  respond_to "brew cask" "return 1"
  run cask status something
  [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}

@test "cask status reports an app is missing" {
  run cask status missing_app
  [ "$status" -eq $STATUS_MISSING ]
}

@test "cask status reports an app is current" {
  run cask status installed_app
  [ "$status" -eq $STATUS_MISSING ]
}

@test "cask status reports an app is outdated" {
  respond_to "brew cask info installed_package" "cat $fixtures/cask-outdated-info.txt"
  run cask status installed_package
  [ "$status" -eq $STATUS_OUTDATED ]
}

@test "cask install runs 'install'" {
  run cask install missing_package
  [ "$status" -eq 0 ]
  run baked_output
  [ "$output" = 'brew cask install missing_package' ]
}

@test "cask upgrade performs a force install and cleans up old versions" {
  run cask upgrade installed_package
  [ "$status" -eq 0 ]
  run baked_output
  [ "${lines[0]}" = "rm -rf /opt/homebrew-cask/Caskroom/installed_package" ]
  [ "${lines[1]}" = "brew cask install installed_package --force" ]
}
