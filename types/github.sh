# TODO
# - if action is compile, then we need to output the entire "git" type as a function.
# - some flag for git:// urls

action=$1
repo=$2
shift 2

. $BORK_SOURCE_DIR/types/git.sh $action \
  "https://github.com/$(echo $repo).git" $*
