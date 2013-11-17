# TODO
# * fetches updates from remote
# * uses merge instead of pull
# * specify alternate ref than "master"
# * "tmpdir" option?
# * "--shallow" option?

cmd="command git"

action=$1
git_url=$2
shift 2

git_name=$(basename $git_url .git)
git_dir="$(destination)/$git_name"
git_branch="master"

case $action in
  depends) echo "exec: git" ;;
  status)
    # if the directory is missing, it's missing
    [ ! -d $git_dir ] && return 10

    # if the directory is present but empty, it's missing
    git_dir_contents=$(str_item_count "$(ls -A $git_dir)")
    [[ $git_dir_contents = 0 ]] && return 10

    git_stat="$(cd $git_dir; $cmd status -uno -b --porcelain)"
    # If the directory isn't a git repo, conflict
    [ $? -ne 0 ] && return 20
    if str_matches "$git_stat" '"^fatal"'; then return 20; fi

    git_first_line=$(echo "$git_stat" | head -n 1)

    # str_matches "$git_first_line" "^\#\# $git_branch"
    str_matches "$(str_get_field "$git_first_line" 2)" "$git_branch"
    if [ "$?" -ne 0 ]; then return 20; fi

    git_divergence=$(str_get_field "$git_first_line" 3)
    if str_matches "$git_divergence" 'ahead'; then return 20; fi

    # are there changes?
    # git_change_match="'^\\s\\?\\w'"
    if str_matches "$git_stat" "^\\s\\?\\w"; then return 20; fi
    # if str_matches "$git_stat" $git_change_match; then return 20; fi

    # # If it's known to be behind, outdated
    if str_matches "$git_divergence" 'behind'; then return 11; fi

    # git_fetch=$(cd $git_dir; $cmd fetch --dry-run 2>&1)
    # if str_matches "$git_fetch" "\s\+[a-f0-9]\{7\}\.\.[a-f0-9]\{7\}"; then return 11; fi

    # guess we're clean, so things are OK
    ;;
  install)
    bake "mkdir -p $git_dir"
    bake "$cmd clone $git_url $git_dir"
    ;;
  upgrade)
    bake "$cmd --git-dir=$git_dir pull"
    bake "$cmd --git-dir=$git_dir log HEAD@{1}.."
    ;;
  *) return 1 ;;
esac
