#!/usr/bin/env bats

. test/helpers.sh
mas () { . $BORK_SOURCE_DIR/types/mas.sh $*; }

setup () {
    respond_to "uname -s" "echo Darwin"
    respond_to "mas list" "cat $fixtures/mas-list.txt"
    respond_to "mas outdated" "cat $fixtures/mas-outdated.txt"
}

@test "mas status: returns FAILED_PRECONDITION without mas exec" {
    respond_to "which mas" "return 1"
    run mas status 497799835 Xcode
    [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}

@test "mas status: returns MISSING when app not installed" {
    run mas status 477670270 2Do
    [ "$status" -eq $STATUS_MISSING ]
}

@test "mas status: returns OUTDATED when app upgrade pending" {
    run mas status 458034879 Dash
    [ "$status" -eq $STATUS_OUTDATED ]
}

@test "mas status: returns OK when app installed and up-to-date" {
    run mas status 497799835 Xcode
    [ "$status" -eq $STATUS_OK ]
}

@test "mas install: performs install" {
    run mas install 477670270 2Do
    [ "$status" -eq 0 ]
    run baked_output
    [ "$output" = 'mas install 477670270' ]
}

@test "mas upgrade: performs upgrade" {
    run mas upgrade 458034879 Dash
    [ "$status" -eq 0 ]
    run baked_output
    [ "$output" = 'mas upgrade' ]
}
