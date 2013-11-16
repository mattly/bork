has_exec () {
  which $1 > /dev/null
}

platform=$(uname -s)
is_platform () {
  [ "$platform" = $1 ]
  return $?
}

