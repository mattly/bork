#!/usr/bin/env bats

. test/helpers.sh

apt () { . $BORK_SOURCE_DIR/core/apt.sh $*; }

apt_responder () {
  case "$1 $2" in
    "dpkg --get-selections") cat "$fixtures/apt-dpkg-dependencies.txt" ;;
    "sudo apt-get")
      shift 2
      case "$*" in
        "-u update --dry-run") cat "$fixtures/apt-update-dry.txt" ;;
      esac
      ;;
  esac
}

baking_responder='apt_responder'

@test "apt status reports a package is missing" {
  run apt status missing_package
  [ "$status" -eq 10 ]
}

@test "apt status reports a package is outdated" {
  run apt status outdated_package
  [ "$status" -eq 11 ]
}

@test "apt status reports a package is current" {
  run apt status current_package
  [ "$status" -eq 0 ]
}

@test "apt install runs 'apt-get install'" {
  run apt install missing_package
  [ "$status" -eq 0 ]
  run baked_output
  [ "$output" = 'sudo apt-get --yes install missing_package' ]
}

@test "apt upgrade runs 'apt-get upgrade'" {
  run apt upgrade outdated_package
  [ "$status" -eq 0 ]
  run baked_output
  [ "$output" = 'sudo apt-get --yes install outdated_package' ]
}

