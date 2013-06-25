lookups=$(cat <<EOF
dialogs.expandAll: NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
dialogs.expandAll: NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

ui.fast: NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
ui.fast: NSGlobalDomain NSWindowResizeTime .001

showAllFiles: NSGlobalDomain AppleShowAllExtensions -bool true
finder.disableNetworkDS: com.apple.desktopservices DSDontWriteNetworkStores -bool true

dock.autohide: com.apple.dock autohide -bool true
dock.static: com.apple.dock static-only -bool true

timeMachine.off: com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
EOF)

osx () {
  directives=$(echo "$lookups" | grep -e "$1:\s\+")
  echo "$directives" | while read directive; do
    domain=$(get_field "$directive" 2)
    key=$(get_field "$directive" 3)
    val_or_type=$(get_field "$directive" 4)

    if matches "$val_or_type" "^\-"; then
      type=$val_or_type
      val=$(get_field "$directive" 5)
    else
      type='-string'
      val=$val_or_type
    fi

    existing_val=$(defaults read "$domain" "$key")
    existing_type="$(get_field "$(defaults read-type "$domain" "$key")" 3)"

    type_matches=false
    val_matches=false

    if [[ "$existing_type" = "-$type" ]]; then
      type_matches=true
    elif [[ "$existing_type" = "boolean" ]] && [[ "$type" = "-bool" ]]; then
      type_matches=true
      if [[ $existing_val = 0 ]] && [[ $val = "false" ]]; then
        val_matches=true
      elif [[ $existing_val = 1 ]] && [[ $val = "true" ]]; then
        val_matches=true
      fi
    fi

    if [[ "$val" = "$existing_val" ]]; then
      val_matches=true
    fi

    if [[ $val_matches = false ]] || [[ $type_matches = false ]]; then
      c="defaults write $domain $key $type $value"
      echo "$c"
    fi
  done
}
