#!/usr/bin/env bats

. test/helpers.sh

apt () { . $BORK_SOURCE_DIR/core/apt.sh $*; }

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
  command_apt_get="test_apt"
  command_apt_list="dpkg_get_selections"
  command_apt_outdated="apt_upgrade_dry"
  baked_output=$(mktemp -t apttest)
}

@test "apt status reports a package is missing" {
  run apt status missing_package
  [ "$status" -eq 10 ]
}

@test "apt status reports a package is outdated" {
  run apt status outdated_package
  [ "$status" -eq 11 ]
}

@test "apt status reports a package is current" {
  run apt status current_package
  [ "$status" -eq 0 ]
}

@test "apt install runs 'apt-get install'" {
  run apt install missing_package
  [ "$status" -eq 0 ]
  [ "$(baked_output)" = 'test_apt --yes install missing_package' ]
}

@test "apt upgrade runs 'apt-get upgrade'" {
  run apt upgrade outdated_package
  [ "$status" -eq 0 ]
  [ "$(baked_output)" = 'test_apt --yes install outdated_package' ]
}

