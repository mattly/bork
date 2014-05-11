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

@test "file install: ignores directory if not present" {
  run file install target source
  [ "$status" -eq 0 ]
  run baked_output
  [ "${lines[0]}" = "cp source target" ]
}

# -- with permission argument ------------------------
@test "file status: returns 11 when target file has incorrect permissions" {
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
  [ "${lines[1]}" = "chmod 700 target" ]
}

# -- with owner argument -----------------------------
@test "file status: returns 40 when target user doesn't exist" {
  respond_to "id -u kermit" "echo 'id: kermit: no such user'; return 1"
  run file status target Readme.md --owner=kermit
  [ "$status" -eq 40 ]
  [ "${lines[0]}" = "unknown owner: kermit" ]
}

@test "file status: returns 11 when target file has incorrect owner" {
  respond_to "sudo md5 -q target" "echo $readsum"
  respond_to "sudo ls -l target" "echo -rw-r--r--  1 kermit  staff  4604"
  run file status target Readme.md --owner=bork
  [ "$status" -eq 11 ]
  [ "${lines[0]}" = "expected owner: bork" ]
  [ "${lines[1]}" = "received owner: kermit" ]
}

@test "file status: returns 0 with owner and all is well" {
  respond_to "sudo md5 -q target" "echo $readsum"
  respond_to "sudo ls -l target" "echo -rw-r--r--  1 kermit  staff  4604"
  run file status target Readme.md --owner=kermit
  [ "$status" -eq 0 ]
}

@test "file install: copies file as correct user" {
  run file install path/to/target path/from/source --owner=kermit
  [ "$status" -eq 0 ]
  run baked_output
  [ "${lines[0]}" = "sudo mkdir -p path/to" ]
  [ "${lines[1]}" = "sudo chown kermit path/to" ]
  [ "${lines[2]}" = "sudo cp path/from/source path/to/target" ]
  [ "${lines[3]}" = "sudo chown kermit path/to/target" ]
}

# --- compile ----------------------------------------
@test "file compile: echoes base64 representation to screen" {
  run file compile path/to/target Readme.md
  [ "$status" -eq 0 ]
  expected="borkfiles__UmVhZG1lLm1kCg=\"$(base64 Readme.md)\""
  [ "${lines[2]}" = $expected ]
}

@test "file status: if compiled, uses stored variable" {
  skip
}

@test "file install: if compiled, uses stored variable" {
  skip
}

