destination () {
  echo "deprecation warning: 'destination' utility will be removed in a future version - use 'cd' instead" 1>&2
  cd $1
}
