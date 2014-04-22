# helpers related to the "compile" operation

# are we compiling?
is_compiling () {
  [ $operation = "compile" ] && return 0 || return 1
}
# are we running from a compiled script?
is_compiled () {
  [ -n "$BORK_IS_COMPILED" ] && return 0 || return 1
}

# multiline, keeps list of compiled types
bag init compiled_types

# TODO: test
# interface for the compiled_type multiline
compiled_type_push () {
  bag push compiled_types "$1"
}
# TODO: test
# interface for the compiled_type multiline
compiled_type_exists () {
  exists=$(bag find compiled_types "^$1\$")
  [ -n "$exists" ]
  return $?
}

# if compiling, echoes a function that contains the given assertion
# include_assertion_for_compiling $assertion_type $file_path
# - $assertion_type: key for the assertion
# - $file_path: absolute/relative path to the file
#
# returns immediately with 0 if not compiling
include_assertion () {
  if ! is_compiling; then return 0; fi
  type=$1
  if compiled_type_exists $type; then return 0; fi
  file=$2
  compiled_type_push $type
  echo "# $file"
  echo "type_$type () {"
  echo "$(cat $file)"
  echo "}"
}
