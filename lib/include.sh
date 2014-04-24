# TODO maybe script dir should be a stack?
include () {
  if [ -e "$BORK_SCRIPT_DIR/$1" ]; then
    # if [ $operation = 'build' ]; then
    #   echo "$scriptDir/$1"
    # else
      . "$BORK_SCRIPT_DIR/$1"
    # fi
  else
    echo "include: $BORK_SCRIPT_DIR/$1: No such file or directory"
    exit 1
  fi
}

