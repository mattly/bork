# TODO some flag for git:// urls

if [ -z "$git_call" ]; then
  git_call=". $BORK_SOURCE_DIR/types/git.sh"
  is_compiled && git_call="git"
fi

action=$1
repo=$2
shift 2

case $action in
  desc)
    echo "front-end for git type, uses github urls"
    echo "passes arguments to git type"
    echo "> ok github mattly/bork"
    echo "> ok github ~/code/bork mattly/bork"
    echo "--ssh                    (clones via ssh instead of https)"
    ;;

  compile)
    include_assertion git $BORK_SOURCE_DIR/types/git.sh
    ;;

  status|install|upgrade)
    next=$1
    target_dir=
    if [ -n "$next" ] && [ ${next:0:1} != '-' ]; then
      target_dir="$repo"
      repo=$1
      shift
    fi
    args="$@"
    if [ -n  "$(arguments get ssh $*)" ]; then
      url="git@github.com:$(echo $repo).git"
      args=$(echo "$args" | sed -E 's|--ssh||')
    else
      url="https://github.com/$(echo $repo).git"
    fi
    eval "$git_call $action '$target_dir' '$url' $args"
    ;;

  *) return 1 ;;
esac
