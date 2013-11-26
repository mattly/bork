has_exec () {
  test_cmd=$1
  shift
  bin=$(str_get_field "$test_cmd" 1)
  which "$bin" > /dev/null
  [ "$?" -ne 0 ] && return 127
  if [ -n "$1" ]; then
    output=$($test_cmd)
    [ "$?" -ne 0 ] && return 1
    for arg in $*; do
      str_matches "$output" "$arg"
      [ "$?" -ne 0 ] && return 2
    done
  fi
  return 0
}

platform=$(uname -s)
is_platform () {
  [ "$platform" = $1 ]
  return $?
}

