#!/usr/bin/env bats

. test/helpers.sh
gem () { . $BORK_SOURCE_DIR/core/gem.sh $*; }

setup () {
  respond_to "gem list" "cat $fixtures/gem-list.txt"
}

@test "gem status: returns FAILED_PRECONDITION without gem exec" {
  respond_to "which gem" "return 1"
  run gem status foo
  [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}

@test "gem status: returns MISSING if gem isn't installed" {
  run gem status baz
  [ "$status" -eq $STATUS_MISSING ]
}

@test "gem status: returns OK if gem is installed" {
  run gem status foo
  [ "$status" -eq $STATUS_OK ]
}

@test "gem install: performs the installation" {
  run gem install foo
  [ "$status" -eq 0 ]
  run baked_output
  [ "${lines[0]}" = "sudo gem install foo" ]
}
