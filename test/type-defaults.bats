#!/usr/bin/env bats

. test/helpers.sh
defaults () { . $BORK_SOURCE_DIR/types/defaults.sh $*; }

@test "defaults status: returns FAILED_PRECODITION without defaults exec" {
  respond_to "which defaults" "return 1"
  run defaults status foodomain fookey string bar
  [ "$status" -eq $STATUS_FAILED_PRECONDITION ]
}

@test "defaults status: returns MISSING if no value for domain/key" {
  respond_to "defaults read MissingDomain MissingKey" \
    "echo '2014-06-29 13:47:17.155 defaults[31031:507]'; echo 'The domain/default pair of \(MissingDomain, MissingKey\) does not exist'; return 1"
  run defaults status MissingDomain MissingKey string something
  [ "$status" -eq $STATUS_MISSING ]
}

@test "defaults status: returns MISMATCH_UPGRADE when existing type doesn't match" {
  respond_to "defaults read-type NSGlobalDomain AppleEnableMenuBarTransparency" "echo 'Type is boolean'"
  run defaults status NSGlobalDomain AppleEnableMenuBarTransparency integer 0
  [ "$status" -eq $STATUS_MISMATCH_UPGRADE ]
}

@test "defaults status: returns MISMATCH_UPGRADE when existing value doesn't match" {
  respond_to "defaults read-type NSGlobalDomain AppleEnableMenuBarTransparency" "echo 'Type is boolean'"
  respond_to "defaults read NSGlobalDomain AppleEnableMenuBarTransparency" "echo 0"
  run defaults status NSGlobalDomain AppleEnableMenuBarTransparency bool true
  [ "$status" -eq $STATUS_MISMATCH_UPGRADE ]
}

@test "defaults status: returns OK when existing type and value matches" {
  respond_to "defaults read-type NSGlobalDomain AppleEnableMenuBarTransparency" "echo 'Type is boolean'"
  respond_to "defaults read NSGlobalDomain AppleEnableMenuBarTransparency" "echo 0"
  run defaults status NSGlobalDomain AppleEnableMenuBarTransparency bool false
  [ "$status" -eq $STATUS_OK ]
}
