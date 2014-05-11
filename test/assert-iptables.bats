#!/usr/bin/env bats

. test/helpers.sh

iptables () { . $BORK_SOURCE_DIR/core/iptables.sh $*; }

@test "iptables status: returns 10 when rule is missing" {
  respond_to "sudo iptables -C INPUT -i lo -j ACCEPT" \
    "echo 'iptables: Bad rule (does a matching rule exist in that chain?).' >&2; return 1"
  run iptables status "INPUT -i lo -j ACCEPT"
  [ "$status" -eq 10 ]
}

@test "iptables status: returns 0 when rule is present" {
  run iptables status "INPUT -i lo -j ACCEPT"
  [ "$status" -eq 0 ]
}

