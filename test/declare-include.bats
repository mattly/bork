#!/usr/bin/env bats

. test/helpers.sh

@test "include: maintains relative directories" {
    run include "test/fixtures/include-one.sh"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = 'one' ]
    [ "${lines[1]}" = 'two' ]
}
