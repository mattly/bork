#!/usr/bin/env bats

. test/helpers.sh

apt () { . $BORK_SOURCE_DIR/types/apt.sh $*; }

setup () {
  respond_to "uname -s" "echo Linux"
  respond_to "dpkg --get-selections" "cat $fixtures/apt-dpkg-dependencies.txt"
  respond_to "sudo apt-get upgrade --dry-run" "cat $fixtures/apt-upgrade-dry.txt"
}

@test "apt status reports incorrect platform" {
  respond_to "uname -s" "echo Darwin"
  run apt status some_package
  [ "$status" -eq $STATUS_UNSUPPORTED_PLATFORM ]
}

@test "apt status reports missing apt-get" {
  respond_to "which apt-get" "return 1"
  run apt status some_package
  [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}
@test "apt status reports missing dpkg" {
  respond_to "which dpkg" "return 1"
  run apt status some_package
  [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}

@test "apt status reports a package is missing" {
  run apt status missing_package
  [ "$status" -eq $STATUS_MISSING ]
}

@test "apt status reports a package is outdated" {
  run apt status outdated_package
  [ "$status" -eq $STATUS_OUTDATED ]
}

@test "apt status reports a package is current" {
  run apt status current_package
  [ "$status" -eq $STATUS_OK ]
}

@test "apt install runs 'apt-get install'" {
  run apt install missing_package
  [ "$status" -eq $STATUS_OK ]
  run baked_output
  [ "$output" = 'sudo apt-get --yes install missing_package' ]
}

@test "apt upgrade runs 'apt-get upgrade'" {
  run apt upgrade outdated_package
  [ "$status" -eq $STATUS_OK ]
  run baked_output
  [ "$output" = 'sudo apt-get --yes install outdated_package' ]
}

