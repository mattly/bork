#!/user/bin/env bats

. test/helpers.sh
user () { . $BORK_SOURCE_DIR/core/user.sh $*; }

users_query="cat /etc/passwd"
groups_query="groups existant"
setup () {
  respond_to "$users_query"   "cat $fixtures/user-list.txt"
  respond_to "$groups_query"  "echo 'bee existant '"
}

# --- without arguments ----------------------------------------
@test "user status: returns 10 when user doesn't exist" {
  run user status nonexistant
  [ "$status" -eq 10 ]
}

@test "user status: returns 0 when user exists" {
  run user status existant
  [ "$status" -eq 0 ]
}

@test "user install: bakes 'useradd' with -m" {
  run user install nonexistant
  [ "$status" -eq 0 ]
  run baked_output
  [ "${#lines[*]}" -eq 1 ]
  [ "${lines[0]}" = "useradd -m nonexistant" ]
}

# --- with shell argument -------------------------------------
@test "user status: with shell, returns 10 when user doesn't exist" {
  run user status nonexistant --shell=/bin/zsh
  [ "$status" -eq 10 ]
}

@test "user status: with shell, returns 11 when user exists, wrong shell" {
  run user status existant --shell=/bin/zsh
  [ "$status" -eq 11 ]
  [ "${#lines[*]}" -eq 1 ]
  echo "${lines[0]}" | grep -E "^--shell:" >/dev/null
  echo "${lines[0]}" | grep -E "/bin/bash$" >/dev/null
}

@test "user status: with shell, returns 0 when user exists, right shell" {
  run user status existant --shell=/bin/bash
  [ "$status" -eq 0 ]
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
@test "user status: with group, returns 10 when user doesn't exist" {
  run user status nonexistant --groups=foo,bar
  [ "$status" -eq 10 ]
}

@test "user status: with group, returns 11 when user belongs to none" {
  run user status existant --groups=foo,bar
  [ "$status" -eq 11 ]
  [ "${#lines[*]}" -eq 1 ]
  echo "${lines[0]}" | grep -E "^--groups:" >/dev/null
  echo "${lines[0]}" | grep -E "foo bar$" >/dev/null
}

@test "user status: with group, returns 11 when user belongs to some" {
  run user status existant --groups=foo,bar,bee
  [ "$status" -eq 11 ]
  [ "${#lines[*]}" -eq 1 ]
  echo "${lines[0]}" | grep -E "^--groups:" >/dev/null
  echo "${lines[0]}" | grep -E "foo bar$" > /dev/null
}

@test "user status: with group, returns 0 when user belongs to all" {
  run user status existant --groups=existant,bee
  [ "$status" -eq 0 ]
}

@test "user install: with group, bakes 'useradd' with --groups" {
  run user install nonexistant --groups=foo,bar
  [ "$status" -eq 0 ]
  run baked_output
  [ "${#lines[*]}" -eq 1 ]
  [ "${lines[0]}" = "useradd -m --groups foo,bar nonexistant" ]
}

@test "user upgrade: with group, bakes 'adduser' with user and group for each group" {
  run user upgrade existant --groups=foo,bar
  [ "$status" -eq 0 ]
  run baked_output
  [ "${#lines[*]}" -eq 4 ]
  [ "${lines[0]}" = $users_query ]
  [ "${lines[1]}" = $groups_query ]
  [ "${lines[2]}" = "useradd existant foo" ]
  [ "${lines[3]}" = "useradd existant bar" ]
}
