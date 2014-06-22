# TODO
# - some flag for git:// urls

action=$1
repo=$2
shift 2

if [ "$action" = "compile" ]; then
  include_assertion git $BORK_SOURCE_DIR/types/git.sh
else
  . $BORK_SOURCE_DIR/types/git.sh $action \
    "https://github.com/$(echo $repo).git" $*
fi

