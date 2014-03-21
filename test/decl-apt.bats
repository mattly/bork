#!/usr/bin/env bats

. test/helpers.sh
. declarations/apt.sh

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
  bork_setup_apt "list_cmd" "dpkg_get_selections"
  bork_setup_apt "outdated_cmd" "apt_upgrade_dry"
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
