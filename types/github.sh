# TODO
# - some flag for git:// urls

action=$1
repo=$2
shift 2
branch=$(arguments get branch $*)

case $action in
  desc)
    echo "front-end for git type, uses github urls"
    echo "> ok github mattly/bork"
    echo "--branch=gh-pages        (specify branch)"
    ;;
  compile)
    include_assertion git $BORK_SOURCE_DIR/types/git.sh
    ;;
  *)
    if [[ -z $branch ]]; then
      . $BORK_SOURCE_DIR/types/git.sh $action "https://github.com/$(echo $repo).git" $*
    else
      . $BORK_SOURCE_DIR/types/git.sh $action "https://github.com/$(echo $repo).git" --branch=$branch $*
    fi
    ;;
esac
