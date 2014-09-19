#!/usr/bin/env bats
# TODO: how have CI run yum tests?

. test/helpers.sh

yum () { . $BORK_SOURCE_DIR/types/yum.sh $*; }

setup () {
  respond_to "uname -s" "echo Linux"
  respond_to "rpm -qa" "cat $fixtures/rpm-qa.txt"
  respond_to "sudo yum list updates" "cat $fixtures/yum-list-updates.txt"
}

@test "yum status reports incorrect platform" {
  respond_to "uname -s" "echo Darwin"
  run yum status some_package
  [ "$status" -eq $STATUS_UNSUPPORTED_PLATFORM ]
}

@test "yum status reports missing yum" {
  respond_to "which yum" "return 1"
  run yum status some_package
  [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}

@test "yum status reports a package is missing" {
  run yum status missing_package
  [ "$status" -eq $STATUS_MISSING ]
}

@test "yum status reports a package is outdated" {
  run yum status outdated_package
  [ "$status" -eq $STATUS_OUTDATED ]
}

@test "yum status reports a package is current" {
  run yum status current_package
  [ "$status" -eq $STATUS_OK ]
}

@test "yum install runs 'yum install'" {
  run yum install missing_package
  [ "$status" -eq $STATUS_OK ]
  run baked_output
  [ "$output" = 'sudo yum -y install missing_package' ]
}
