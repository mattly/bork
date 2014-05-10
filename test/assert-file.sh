#!/usr/bin/env bats

. test/helpers.sh

file () { . $BORK_SOURCE_DIR/core/file.sh $*; }

setup () {
  readsum=$(eval $(md5cmd $platform Readme.md))
  platform=Darwin
}

# -- without arguments -------------------------------
@test "file status: returns 10 when file is missing" {
  respond_to "[ -f missing ]" "return 1"
  run file status missing path/to/missing
  [ "$status" -eq 10 ]
}

@test "file status: returns 40 when source file is missing" {
  run file status somefile missingfile
  [ "$status" -eq 40 ]
}

@test "file status: returns 20 when sum doesn't match" {
  respond_to "md5 -q wrongfile" "echo 123456"
  run file status wrongfile Readme.md
  [ "$status" -eq 20 ]
  expected="expected sum: $readsum"
  [ "${lines[0]}" = $expected ]
  [ "${lines[1]}" = "received sum: 123456" ]
}

@test "file status: returns 0 when all is well" {
  respond_to "md5 -q goodfile" "echo $readsum"
  run file status goodfile Readme.md
  [ "$status" -eq 0 ]
}

@test "file install: creates directory, copies file" {
  run file install path/to/target path/from/source
  [ "$status" -eq 0 ]
  run baked_output
  [ "${lines[0]}" = "mkdir -p path/to" ]
  [ "${lines[1]}" = "cp path/from/source path/to/target" ]
}

# -- with permission argument ------------------------
@test "file status: returns 11 when source file has incorrect permissions" {
  respond_to "md5 -q tfile" "echo $readsum"
  respond_to "stat -f '%Lp' tfile" "echo 755"
  run file status tfile Readme.md --permissions=700
  [ "$status" -eq 11 ]
  [ "${lines[0]}" = "expected permissions: 700" ]
  [ "${lines[1]}" = "received permissions: 755" ]
}

@test "file install: sets permissions for file after copying" {
  run file install target path/from/source --permissions=700
  [ "$status" -eq 0 ]
  run baked_output
  p $output
  [ "${lines[2]}" = "chmod 700 target" ]
}

