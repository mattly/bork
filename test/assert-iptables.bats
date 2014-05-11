#!/usr/bin/env bats

. test/helpers.sh

iptables () { . $BORK_SOURCE_DIR/core/iptables.sh $*; }

@test "iptables status: returns MISSING when rule is missing" {
  respond_to "sudo iptables -C INPUT -i lo -j ACCEPT" \
    "echo 'iptables: Bad rule (does a matching rule exist in that chain?).' >&2; return 1"
  run iptables status "INPUT -i lo -j ACCEPT"
  [ "$status" -eq $STATUS_MISSING ]
}

@test "iptables status: returns OK when rule is present" {
  run iptables status "INPUT -i lo -j ACCEPT"
  [ "$status" -eq $STATUS_OK ]
}

@test "iptables install: bakes the -A command" {
  run iptables install "INPUT -i lo -j ACCEPT"
  [ "$status" -eq 0 ]
  run baked_output
  [ "${lines[0]}" = "sudo iptables -A INPUT -i lo -j ACCEPT" ]
}
