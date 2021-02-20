#!/usr/bin/env bats

. test/helpers.sh

apk() { . $BORK_SOURCE_DIR/types/apk.sh "$@"; }

@test "apk status returns FAILED_PRECONDITION when apk is missing" {
  respond_to 'which apk' 'return 1'
  run apk status something
  (( status == STATUS_FAILED_PRECONDITION ))
}

@test "apk status returns MISSING when package is not installed" {
  respond_to 'apk info --installed missing_package_is_missing' \
    'return 1'

  run apk status missing_package_is_missing
  (( status == STATUS_MISSING ))
}

@test "apk status returns OK when packge is installed and current" {
  respond_to 'apk info --installed current_package' \
    'echo current_package'

  run apk status current_package
  echo "$output"
  (( status == STATUS_OK ))
}

@test "apk status returns OUTDATED when package is installed but outdated" {
  respond_to "apk version" "cat $fixtures/apk-version.txt"

  run apk status outdated_package
  echo "$output"
  (( status == STATUS_OUTDATED ))
}

@test "apk install runs 'add pkg'" {
  run apk install missing_package_is_missing
  (( status == 0 ))
  run baked_output
  [[ ${output} == 'sudo apk add missing_package_is_missing' ]]
}

@test "apk upgrade runs 'add pkg'" {
  run apk upgrade outdated_package
  (( status == 0 ))
  run baked_output
  [[ ${output} == 'sudo apk add outdated_package' ]]
}

@test "apk delete runs 'del pkg'" {
  run apk delete current_package
  (( status == 0 ))
  run baked_output
  [[ ${output} == 'sudo apk del current_package' ]]
}
