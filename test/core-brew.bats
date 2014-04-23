#!/usr/bin/env bats

. test/helpers.sh
brew () { . $BORK_SOURCE_DIR/core/brew.sh $*; }

brew_responder () {
  case "$1 $2" in
    "brew list") cat "$fixtures/brew-list.txt" ;;
    "brew outdated") cat "$fixtures/brew-outdated.txt" ;;
  esac
}
baking_responder='brew_responder'

@test "brew status reports a package is missing" {
  run brew status missing_package_is_missing
  [ "$status" -eq 10 ]
}

@test "brew status reports a package is outdated" {
  run brew status outdated_package
  [ "$status" -eq 11 ]
}

@test "brew status reports a packge is current" {
  run brew status current_package
  [ "$status" -eq 0 ]
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

