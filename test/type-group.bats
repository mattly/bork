#!/usr/bin/env bats

. test/helpers.sh
group () { . $BORK_SOURCE_DIR/types/group.sh $*; }

setup () {
  respond_to "cat /etc/group" "echo 'root:x:0'; echo 'admin:x:50'"
}

@test "group status: returns FAILED_PRECONDITION when missing groupadd exec" {
  respond_to "which groupadd" "return 1"
  run group status foo
  [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}

@test "group status: returns MISSING when group doesn't exist" {
  run group status custom
  [ "$status" -eq $STATUS_MISSING ]
}

@test "group status: returns OK when group exists" {
  run group status admin
  [ "$status" -eq $STATUS_OK ]
}

@test "group install: bakes 'groupadd'" {
  run group install custom
  [ "$status" -eq 0 ]
  run baked_output
  [ "${#lines[*]}" -eq 1 ]
  [ "${lines[0]}" = "groupadd custom" ]
}
