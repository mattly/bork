#!/usr/bin/env bats

. test/helpers.sh

@test "md5cmd Darwin echoes 'md5'" {
  run md5cmd Darwin
  [ "$status" -eq 0 ]
  p "$output"
  [ "$output" = "md5" ]
}

@test "md5cmd Darwin :file echoes 'md5 :file'" {
  run md5cmd Darwin Readme.md
  [ "$status" -eq 0 ]
  [ "$output" = "md5 Readme.md" ]
}

@test "md5cmd Linux echoes md5sum with awk" {
  run md5cmd Linux
  [ "$status" -eq 0 ]
  [ "$output" = "md5sum | awk '{print \$1}'" ]
}

@test "md5cmd Linux :file echoes md5sum :file with awk" {
  run md5cmd Linux Readme.md
  [ "$status" -eq 0 ]
  [ "$output" = "md5sum Readme.md | awk '{print \$1}'" ]
}

@test "md5cmd BSD returns 1" {
  run md5cmd BSD
  [ "$status" -eq 1 ]
}
