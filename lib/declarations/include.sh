# TODO maybe script dir should be a stack?
include () {
  if [ -e "$BORK_SCRIPT_DIR/$1" ]; then
    . "$BORK_SCRIPT_DIR/$1"
  else
    echo "include: $BORK_SCRIPT_DIR/$1: No such file or directory"
    exit 1
  fi
}

