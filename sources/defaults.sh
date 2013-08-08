defaults() {
  domain=$1
  key=$2
  if matches "$3" "^\-"; then
    desired_type=$3
    desired_val=$4
  else
    desired_type="-string"
    desired_val=$3
  fi

  current_type="$(get_field "$(command defaults read-type $domain $key)" 3)"
  type_matches=false
  current_val=$(command defaults read $1 $2)
  val_matches=false

  if [[ "$current_type" = "boolean" ]]; then
    current_type="bool"
    if [[ $current_val = 0 ]]; then current_val="false"; fi
    if [[ $current_val = 1 ]]; then current_val="true"; fi
  fi
  if [ "$current_type" = "-$desired_type" ]; then type_matches=true; fi
  if [[ "$current_val" = "$desired_val" ]]; then val_matches=true; fi

  if [[ $val_matches = false ]] || [[ $type_matches = false ]]; then
    bake "defaults write $domain $key $desired_type $desired_val"
  fi
}
