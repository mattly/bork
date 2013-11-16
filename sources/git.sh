cmd="command git"

git_url=$1
git_name=$(basename $git_url .git)
git_dir="$(destination)/$git_name"
git_branch="master"

mode=$(bork_mode)
case $mode in
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
esac

# git () {
#   git_url=$1
#   dir=$2
#   if [ -z $dir ]; then
#     repo_name=$(basename $1 .git)
#     dir="$current_destination/$repo_name"
#   fi
#   if [ ! -d $dir ]; then
#     bake "mkdir -p $dir"
#     bake "command git clone $git_url $dir"
#   else
#     fetch=$(cd $dir; command git fetch --dry-run 2>&1 )
#     if matches "$fetch" "\s\+[a-f0-9]\{7\}\.\.[a-f0-9]\{7\}" ; then
#       git_update "$dir" "$git_url"
#       return 0
#     fi
#     status=$(cd $dir; command git status )
#     if matches "$status" "Your branch is behind" ; then
#       git_update "$dir" "$git_url"
#     fi
#   fi
# }

# git_update () {
#   [ -n "$2" ] && echo "updating $2"
#   bake --dir $1 "command git pull"
#   bake --dir $1 "command git log HEAD@{1}.."
# }
