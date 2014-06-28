# TODO
# - some flag for git:// urls

action=$1
repo=$2
shift 2

case $action in
  desc)
    echo "front-end for git type, uses github urls"
    echo "* ok github mattly/dotfiles"
    ;;
  compile) include_assertion git $BORK_SOURCE_DIR/types/git.sh ;;
  *) . $BORK_SOURCE_DIR/types/git.sh $action "https://github.com/$(echo $repo).git" $* ;;
esac

