BORK_DESTINATION=
destination () {
  BORK_DESTINATION=$1
  if [ ! -d "$1" ]; then
    echo "missing destination: $1"
    return 1
  fi
}
