#!/usr/bin/env bats

. test/helpers.sh

@test "with curl and head performs a head request" {
    respond_to "which curl" "echo /usr/bin/curl"
    url="https://foo.com"
    respond_to "curl -sI \"https://foo.com\"" "cat $fixtures/http-head-curl.txt"
    run http_head_cmd "$url"
    [ "$status" -eq 0 ]
    [ 'curl -sI "https://foo.com"' = $output ]
}

@test "extracting a header value" {
    input=$(cat "$fixtures/http-head-curl.txt")
    run http_header "Content-Length" "$input"
    [ "312" -eq $output ]
}

@test "getting a file" {
    url="https://foo.com/bar"
    target="/boo/baz"
    run http_get_cmd "$url" "$target"
    [ "$status" -eq 0 ]
    [ "curl -so $target \"$url\" &> /dev/null" = $output ]
}
