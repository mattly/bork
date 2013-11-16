has_exec () {
  which $1 > /dev/null
}

platform=$(uname -s)
is_platform () {
  [ "$platform" = $1 ]
  return $?
}

check_output_for () {
  command=$1
  shift
  output=$($command)
  [ "$?" -ne 0 ] && return 1
  for arg in $*; do
    str_matches "$output" "$arg"
    [ "$?" -ne 0 ] && return 2
  done
  return 0
}
