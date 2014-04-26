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

  case "$operation" in
    compile) base_compile $2 ;;
    satisfy | status) . $2 ;;
  esac
}
