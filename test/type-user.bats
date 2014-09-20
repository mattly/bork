#!/user/bin/env bats

. test/helpers.sh
user () { . $BORK_SOURCE_DIR/types/user.sh $*; }

users_query="cat /etc/passwd"
groups_query="groups existant"
setup () {
  respond_to "$users_query"   "cat $fixtures/user-list.txt"
  respond_to "$groups_query"  "echo 'bee existant '"
}

# --- without arguments ----------------------------------------
@test "user status: returns FAILED_PRECONDITION when useradd isn't found" {
  respond_to "which useradd" "return 1"
  run user status foo
  [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}

@test "user status: returns MISSING when user doesn't exist" {
  run user status nonexistant
  [ "$status" -eq $STATUS_MISSING ]
}

@test "user status: returns OK when user exists" {
  run user status existant
  [ "$status" -eq $STATUS_OK ]
}

@test "user install: bakes 'useradd' with -m" {
  run user install nonexistant
  [ "$status" -eq 0 ]
  run baked_output
  [ "${#lines[*]}" -eq 1 ]
  [ "${lines[0]}" = "useradd -m nonexistant" ]
}

# --- with shell argument -------------------------------------
@test "user status: with shell, returns MISSING when user doesn't exist" {
  run user status nonexistant --shell=/bin/zsh
  [ "$status" -eq $STATUS_MISSING ]
}

@test "user status: with shell, returns MISMATCHED_UPGRADE when user exists, wrong shell" {
  run user status existant --shell=/bin/zsh
  [ "$status" -eq $STATUS_MISMATCH_UPGRADE ]
  [ "${#lines[*]}" -eq 1 ]
  echo "${lines[0]}" | grep -E "^--shell:" >/dev/null
  echo "${lines[0]}" | grep -E "/bin/bash$" >/dev/null
}

@test "user status: with shell, returns OK when user exists, right shell" {
  run user status existant --shell=/bin/bash
  [ "$status" -eq $STATUS_OK ]
}

@test "user install: with shell, bakes 'useradd' with --shell" {
  run user install nonexistant --shell=/bin/zsh
  [ "$status" -eq 0 ]
  run baked_output
  [ "${#lines[*]}" -eq 1 ]
  [ "${lines[0]}" = "useradd -m --shell /bin/zsh nonexistant" ]
}

@test "user upgrade: with shell, bakes 'chsh -s'" {
  run user upgrade existant --shell=/bin/zsh
  [ "$status" -eq 0 ]
  run baked_output
  [ "${#lines[*]}" -eq 3 ]
  [ "${lines[0]}" = $users_query ]
  [ "${lines[1]}" = "chsh -s /bin/zsh existant" ]
  [ "${lines[2]}" = $groups_query ]
}

# --- with group argument ------------------------------------
@test "user status: with group, returns MISSING when user doesn't exist" {
  run user status nonexistant --groups=foo,bar
  [ "$status" -eq $STATUS_MISSING ]
}

@test "user status: with group, returns PARTIAL when user belongs to none" {
  run user status existant --groups=foo,bar
  [ "$status" -eq $STATUS_PARTIAL ]
  [ "${#lines[*]}" -eq 1 ]
  echo "${lines[0]}" | grep -E "^--groups:" >/dev/null
  echo "${lines[0]}" | grep -E "foo bar$" >/dev/null
}

@test "user status: with group, returns PARTIAL when user belongs to some" {
  run user status existant --groups=foo,bar,bee
  [ "$status" -eq $STATUS_PARTIAL ]
  [ "${#lines[*]}" -eq 1 ]
  echo "${lines[0]}" | grep -E "^--groups:" >/dev/null
  echo "${lines[0]}" | grep -E "foo bar$" > /dev/null
}

@test "user status: with group, returns OK when user belongs to all" {
  run user status existant --groups=existant,bee
  [ "$status" -eq $STATUS_OK ]
}

@test "user install: with group, bakes 'useradd' with --groups and -g" {
  run user install nonexistant --groups=foo,bar
  [ "$status" -eq 0 ]
  run baked_output
  [ "${#lines[*]}" -eq 1 ]
  [ "${lines[0]}" = "useradd -m --groups foo,bar -g foo nonexistant" ]
}

@test "user upgrade: with group, bakes 'adduser' with user and group for each group" {
  run user upgrade existant --groups=foo,bar
  [ "$status" -eq 0 ]
  run baked_output
  [ "${#lines[*]}" -eq 4 ]
  [ "${lines[0]}" = $users_query ]
  [ "${lines[1]}" = $groups_query ]
  [ "${lines[2]}" = "adduser existant foo" ]
  [ "${lines[3]}" = "adduser existant bar" ]
}
