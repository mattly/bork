action=$1
repo=$2
shift 2

# TODO this won't survive the build action
. $BORK_SOURCE_DIR/stdlib/git.sh $action \
  "https://github.com/$(echo $repo).git" $*
