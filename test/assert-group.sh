#!/user/bin/env bats

. test/helpers.sh
group () { . $BORK_SOURCE_DIR/core/group.sh $*; }

list_groups () {
  echo "root:x:0:"
  echo "admin:x:50:"
}

setup () {
  group_list_cmd="list_groups"
}

@test "group status: returns 10 when group doesn't exist" {
  run group status custom
  [ "$status" -eq 10 ]
}

@test "group status: returns 0 when group exists" {
  run group status admin
  [ "$status" -eq 0 ]
}

@test "group install: bakes 'groupadd'" {
  run group install custom
  [ "$status" -eq 0 ]
  run baked_output
  [ "${#lines[*]}" -eq 1 ]
  [ "${lines[0]}" = "groupadd custom" ]
}
