# manages assertion types

# is a key/value 'multiline' that keeps track of assertion types and how to
# run them.
assertion_types=

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
  assertion_types=$(multiline add 'assertion_types', "$type=$file")
  include_assertion $type $file
}

# TODO: test
# lookup assertion function
lookup_assertion () {
  assertion=$1
  if is_compiled; then
    echo "type_$assertion"
    return
  fi
  fn=$(multiline key 'assertion_types' $assertion)
  if [ "$?" -eq 0 ]; then
    echo "$fn"
    return
  fi
  bork_official="$BORK_SOURCE_DIR/core/$(echo $assertion).sh"
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

