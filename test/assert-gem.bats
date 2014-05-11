#!/usr/bin/env bats

. test/helpers.sh
gem () { . $BORK_SOURCE_DIR/core/gem.sh $*; }

@test "gem status: returns FAILED_PRECONDITION without gem exec" {
  respond_to "which gem" "return 1"
  run gem status foo
  [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}
