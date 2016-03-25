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
  p "bool"
  p $output
  [ "$status" -eq $STATUS_OK ]
}

@test "defaults status: returns OK when type is int and value matches" {
  respond_to "defaults read-type NSGlobalDomain NSTableViewDefaultSizeMode" "echo 'Type is integer'"
  respond_to "defaults read NSGlobalDomain NSTableViewDefaultSizeMode" "echo 2"
  run defaults status NSGlobalDomain NSTableViewDefaultSizeMode int 2
  p "int"
  p $output
  [ "$status" -eq $STATUS_OK ]
}

@test "defaults status: returns OK when type is dict and value matches" {
  respond_to "defaults read-type com.runningwithcrayons.Alfred-Preferences hotkey.default" "echo 'Type is dictionary'"
  respond_to "defaults read com.runningwithcrayons.Alfred-Preferences hotkey.default" "cat $fixtures/defaults-dictionary-value.txt"
  run defaults status com.runningwithcrayons.Alfred-Preferences hotkey.default dict key -int 49 mod -int 1048576 string space
  [ "$status" -eq $STATUS_OK ]
}

@test "defaults upgrade: runs defaults write with: \$domain \$key -\$type \$value" {
  run defaults upgrade NSGlobalDomain AppleEnableMenuBarTransparency bool false
  [ "$status" -eq 0 ]
  run baked_output
  [ "$output" = "defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false" ]
}

@test "defaults install|upgrade: handles dict with proper args" {
  run defaults install com.runningwithcrayons.Alfred-Preferences hotkey.default dict key -int 49 mod -int 1048576 string Space
  [ "$status" -eq 0 ]
  run baked_output
  [ "$output" = "defaults write com.runningwithcrayons.Alfred-Preferences hotkey.default -dict key -int 49 mod -int 1048576 string Space" ]
}
