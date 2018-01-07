#!/usr/bin/env bats

. test/helpers.sh

zypper() { . $BORK_SOURCE_DIR/types/zypper.sh "$@"; }

@test "zypper status returns FAILED_PRECONDITION when rpm is missing" {
  respond_to 'which rpm' 'return 1'
  run zypper status something
  (( status == STATUS_FAILED_PRECONDITION ))
}

@test "zypper status returns FAILED_PRECONDITION when zypper is missing" {
  respond_to 'which zypper' 'return 1'
  run zypper status something
  (( status == STATUS_FAILED_PRECONDITION ))
}

@test "zypper status returns MISSING when package is not installed" {
  respond_to 'rpm -q missing_package_is_missing' \
    'echo package missing_package_is_missing is not installed; return 1'

  run zypper status missing_package_is_missing
  (( status == STATUS_MISSING ))
}

@test "zypper status returns OK when packge is installed and current" {
  respond_to 'rpm -q current_package' 'echo current_package-1.1.0-1.0.noarch'

  run zypper status current_package
  (( status == STATUS_OK ))
}

@test "zypper status returns OUTDATED when package is installed but outdated" {
  respond_to 'zypper --terse list-updates' \
    "cat ${fixtures}/zypper-list-updates.txt"

  run zypper status outdated_package
  (( status == STATUS_OUTDATED ))
}

@test "zypper install runs 'install pkg'" {
  run zypper install missing_package_is_missing
  (( status == 0 ))
  run baked_output
  [[ ${output} == 'sudo zypper -nt install missing_package_is_missing' ]]
}

@test "zypper upgrade runs 'update pkg'" {
  run zypper upgrade outdated_package
  (( status == 0 ))
  run baked_output
  [[ ${output} == 'sudo zypper -nt update outdated_package' ]]
}

@test "zypper delete runs 'remove pkg'" {
  run zypper delete current_package
  (( status == 0 ))
  run baked_output
  [[ ${output} == 'sudo zypper -nt remove current_package' ]]
}
