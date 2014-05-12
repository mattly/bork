# manages assertion types

# is a bag that keeps track of assertion types their locations
bag init bork_assertion_types

# register a local assertion type
# register $filename
# - $filename: path to a local file to register
#   basename of file is the asertion type.
#
#     register helpers/pip.sh
#     ok pip pygments
#
# exits with status 1 if the file doesn't exist
register () {
  file=$1
  type=$(basename $file '.sh')
  if [ -e "$BORK_SCRIPT_DIR/$file" ]; then
    file="$BORK_SCRIPT_DIR/$file"
  else
    exit 1
  fi
  bag set bork_assertion_types $type $file
}

# lookup assertion function

# yes, this could have been done in fewer lines with a gnarly nested IF/ELSE
# type statement.  I have no interest in saving lines at the cost of clarity.
_lookup_type () {
  assertion=$1
  if is_compiled; then
    echo "type_$assertion"
    return
  fi
  fn=$(bag get bork_assertion_types $assertion)
  if [ -n "$fn" ]; then
    echo "$fn"
    return
  fi
  bork_official="$BORK_SOURCE_DIR/types/$(echo $assertion).sh"
  if [ -e "$bork_official" ]; then
    echo "$bork_official"
    return
  fi
  local_script="$BORK_SCRIPT_DIR/$assertion"
  if [ -e "$local_script" ]; then
    echo "$local_script"
    return
  fi
  return 1
}

