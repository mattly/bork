#!/usr/bin/env bats

. test/helpers.sh
npm () { . $BORK_SOURCE_DIR/types/npm.sh $*; }

setup () {
  respond_to "npm ls -g --depth 0" "cat $fixtures/npm-list.txt"
}

@test "npm status: returns FAILED_PRECONDITION without npm exec" {
  respond_to "which npm" "return 1"
  run npm status nodemon
}

@test "npm status: returns MISSING if package isn't installed" {
  run npm status missing-package
  [ "$status" -eq $STATUS_MISSING ]
}

@test "npm status: returns OK if package is installed" {
  run npm status nodemon
  [ "$status" -eq $STATUS_OK ]
}

@test "npm install: performs an installation" {
  run npm install foo
  [ "$status" -eq 0 ]
  run baked_output
  [ "${lines[0]}" = "npm -g install foo" ]
}
