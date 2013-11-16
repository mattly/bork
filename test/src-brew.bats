#!/usr/bin/env bats

. test/helpers.sh

functionize_thing "sources/brew.sh"

return_status=0
brew_packages=""
brew_outdated=""
bork_operation='status'
test_brew () {
  case $1 in
    list) echo "$brew_packages" ;;
    outdated) echo "$brew_outdated" ;;
  esac
  [ -n $return_status ] && return $return_status
}

setup () {
  return_status=0
  brew_packages=$(
    echo "current_package"
    echo "outdated_package"
  )
  brew_outdated=$(
    echo "outdated_package (0.5 < 0.6)"
    echo "another_outdated_package (0.4 < 0.4.1)"
  )
}

@test "status reports a package is missing" {
  run brew missing_package_is_missing
  [ "$status" -eq 10 ]
}

@test "status reports a package is outdated" {
  run brew outdated_package
  [ "$status" -eq 11 ]
}

@test "status reports a packge is current" {
  run brew current_package
  [ "$status" -eq 0 ]
}
