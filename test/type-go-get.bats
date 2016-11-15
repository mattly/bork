#!/usr/bin/env bats

. test/helpers.sh
go-get () { . $BORK_SOURCE_DIR/types/go-get.sh $*; }

@test "go-get status: returns FAILED_PRECONDITION without go exec" {
  respond_to "which go" "return 1"
  run go-get status foo
  [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}

@test "go-get status: returns MISSING if package isn't installed" {
  respond_to "go list baz" "return 1"
  run go-get status baz
  [ "$status" -eq $STATUS_MISSING ]
}

@test "go-get status: returns OK if package is installed" {
  respond_to "go-get list foo" "return 0"
  run go-get status foo
  [ "$status" -eq $STATUS_OK ]
}

@test "go-get install: performs the installation" {
  run go-get install foo
  [ "$status" -eq 0 ]
  run baked_output
  [ "${lines[0]}" = "go get -u foo" ]
}
