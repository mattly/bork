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
}

