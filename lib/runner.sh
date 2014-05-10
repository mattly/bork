operation=$1

# used by include to find 'include foo/bar.sh'
BORK_SCRIPT_DIR=$(getDir $(pwd -P)/$2)
BORK_WORKING_DIR=$PWD

$BORK_SOURCE_DIR/load.sh

case "$operation" in
  compile) . compile.sh $2 ;;
  satisfy | status) . $2 ;;
  load) : ;;
  *) cat <<END
bork usage:

bork operation [config-file]

where "operatiion" is one of:

status: determine if the config file's conditions are met
satisfy: satisfy the config file's conditions if possible
compile: compile the config file to a self-contained script output to STDOUT
END
  exit 1
  ;;
esac
