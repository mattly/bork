runner () {
  operation=$1

  case $operation in
    status | satisfy | compile)
      if [ ! -e "$2" ]; then
        echo "bork: $1 command requires a config script"
        exit 1
      fi ;;
    *)
      echo "bork: must give 'status' or 'satisfy' as first argument"
      exit 1 ;;
  esac

  # used by include to find 'include foo/bar.sh'
  BORK_SCRIPT_DIR=$(getDir $(pwd -P)/$2)

  BORK_WORKING_DIR=$PWD

  if [ "$operation" = "compile" ]; then
    echo "#!/usr/bin/env bash"
    echo "$setupFn"
    echo "BORK_SCRIPT_DIR=\$PWD"
    echo "BORK_WORKING_DIR=\$PWD"
    for file in $BORK_SOURCE_DIR/lib/*; do
      if [ "$file" != "$BORK_SOURCE_DIR/lib/runner.sh" ]; then cat $file; fi
    done

    target_op=$(arguments get operation $*)
    if [ -n "$target_op" ]; then
      echo "operation=\"$target_op\""
    else
      echo "operation=$1"
    fi
    echo "BORK_IS_COMPILED=1"

    . $2
  else
    . $2
  fi
}
