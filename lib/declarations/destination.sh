BORK_DESTINATION=$BORK_WORKING_DIR
destination () {
  BORK_DESTINATION=$1
  if [ ! -d "$1" ]; then
    echo "missing destination: $1"
    return 1
  fi
}
