# to be called from an assertions's "status" action, to determine is the target
# system has a necessary exec.  Returns 0 if found, $2 + 1 if not.
#
# arguments
# $1: exec to test against.  Will be provided to `which`.
#     required
# $2: running status.  Allows you to "chain" needs exec calls, to easily test
#     multiple `needs_exec` calls and know if any failed.
#     optional, default: 0
needs_exec () {
  [ -z "$1" ] && return 1
  [ -z "$2" ] && running_status=0 || running_status=$2

  # was seeing some weirdness on this where $1 would have carraige returns sometimes, so it's quoted.
  path=$(bake which "$1")

  if [ "$?" -gt 0 ]; then
    echo "missing required exec: $1"
    retval=$((running_status+1))
    return $retval
  else return $running_status
  fi
}


platform=$(uname -s)

# TODO: deprecated in favor of platform_is
is_platform () {
  [ "$platform" = $1 ]
  return $?
}

platform_is () {
  [ "$platform" = $1 ]
  return $?
}

baking_platform=
baking_platform_is () {
  # this is done lazily, to allow time for bake to be reconfigured.
  [ -z "$baking_platform" ] && baking_platform=$(bake uname -s)

  [ "$baking_platform" = $1 ]
  return $?
}
