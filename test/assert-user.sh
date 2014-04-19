#!/user/bin/env bats

. test/helpers.sh
user () { . $BORK_SOURCE_DIR/core/user.sh $*; }

list_users () {
  echo "existant:*:100:100::/home/existant:/bin/bash"
}

setup () {
  user_list_cmd="list_users"
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
  [ "${#lines[*]}" -eq 1 ]
  [ "${lines[0]}" = "chsh -s /bin/zsh existant" ]
}
