#!/usr/bin/env bats

. test/helpers.sh

download () { . $BORK_SOURCE_DIR/types/download.sh $*; }

@test "download status: when file is MISSING" {
    respond_to "[ -f \"missing\" ]" "return 1"
    run download status missing "http://foo.com"
    [ "$status" -eq $STATUS_MISSING ]
}

@test "download status: without comparisons returns OK when file exists" {
    target="foo/bar.txt"
    respond_to "curl -sI \"http://foo.com/bar.txt\"" "return 1"
    run download status "$target" "http://foo.com/bar.txt"
    [ "$status" -eq $STATUS_OK ]
}

@test "download status: returns CONFLICT_UPGRADE when comparing size and it doesn't match" {
    target="foo/bar.txt"
    respond_to "ls -al \"foo/bar.txt\"" \
               "echo '-rw-r--r--   1 mattly  staff  11091 Mar 21 12:55 bar.txt'"
    respond_to "curl -sI \"http://foo.com/bar.txt\"" "cat $fixtures/http-head-curl.txt"
    run download status "$target" "http://foo.com/bar.txt" --size
    [ "$status" -eq $STATUS_CONFLICT_UPGRADE ]
    [ "${#lines[*]}" -eq 2 ]
}

@test "download status: returns OK when conditions match" {
    target="foo/bar.txt"
    respond_to "ls -al \"foo/bar.txt\"" \
               "echo '-rw-r--r--   1 mattly  staff    312 Mar 21 12:55 bar.txt'"
    respond_to "curl -sI \"http://foo.com/bar.txt\"" "cat $fixtures/http-head-curl.txt"
    run download status "$target" "http://foo.com/bar.txt" --size
    [ "$status" -eq $STATUS_OK ]
}

@test "download install: gets from remote" {
    target="foo/bar.txt"
    run download install "$target" "http://foo.com/bar.txt"
    [ "$status" -eq $STATUS_OK ]
    run baked_output
    expected="curl -so \"$target\" \"http://foo.com/bar.txt\" &> /dev/null"
    [[ "${lines[1]}" = $expected ]]
}
