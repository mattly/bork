#!/usr/bin/env bats

. test/helpers.sh
. declarations/apt.sh

baked_output=

dpkg_get_selections () {
  echo "outdated_package              installed"
  echo "current_package               installed"
}
apt_upgrade_dry () {
  echo "Conf current_package"
  echo "Inst outdated_package [1:9.8.1.dfsg.P1-4] (1:9.8.1.dfsg.P1-4ubuntu0.3 Ubuntu:12.04/precise-updates [i386]) []"
  echo "Conf outdated_package"
}

setup () {
  bork_setup_apt "apt_cmd" "test_apt"
  bork_setup_apt "list_cmd" "dpkg_get_selections"
  bork_setup_apt "outdated_cmd" "apt_upgrade_dry"
  baked_output=$(mktemp -t apttest)
}

@test "apt status reports a package is missing" {
  run bork_decl_apt status missing_package
  [ "$status" -eq 10 ]
}

@test "apt status reports a package is outdated" {
  run bork_decl_apt status outdated_package
  [ "$status" -eq 11 ]
}

@test "apt status reports a package is current" {
  run bork_decl_apt status current_package
  [ "$status" -eq 0 ]
}

@test "apt install runs 'apt-get install'" {
  run bork_decl_apt install missing_package
  [ "$status" -eq 0 ]
  [ "$(baked_output)" = 'test_apt --yes install missing_package' ]
}

@test "apt upgrade runs 'apt-get upgrade'" {
  run bork_decl_apt upgrade outdated_package
  [ "$status" -eq 0 ]
  [ "$(baked_output)" = 'test_apt --yes install outdated_package' ]
}

