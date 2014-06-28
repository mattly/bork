# TODO
# - compare origins to ensure correct, provide fix for
# - provide flag for refspec name, ensure status/install/upgrade use it properly
# - perhaps do --depth=0 by default (quicker) & provide flag for --full ?
# - need to dig into submodules?
# - anything here we can extract and re-use for an hg or darcs type?

action=$1
git_url=$2
shift 2

git_name=$(basename $git_url .git)
git_dir="$git_name"
git_branch="master"

case $action in
  desc)
    echo "asserts presence and state of a git repository"
    echo "* git git@github.com:mattly/bork"
    ;;
  status)
    needs_exec "git" || return $STATUS_FAILED_PRECONDITION

    # if the directory is missing, it's missing
    bake [ ! -d $git_dir ] && return $STATUS_MISSING

    # if the directory is present but empty, it's missing
    git_dir_contents=$(str_item_count "$(bake ls -A $git_dir)")
    [ "$git_dir_contents" -eq 0 ] && return $STATUS_MISSING

    bake cd $git_dir
    # fetch from the remote without fast-forwarding
    # this *does* change the local repository's pointers and takes longer
    # up front, but I believe in the grand scheme is the right thing to do.
    git_fetch="$(bake git fetch 2>&1)"
    git_fetch_status=$?

    # If the directory isn't a git repo, conflict
    if [ $git_fetch_status -gt 0 ]; then
      echo "destination directory $git_dir exists, not a git repository (exit status $git_fetch_status)"
      return $STATUS_CONFLICT_CLOBBER
    elif str_matches "$git_fetch" '"^fatal"'; then 
      echo "destination directory exists, not a git repository"
      echo "$git_fetch"
      return $STATUS_CONFLICT_CLOBBER
    fi

    git_stat=$(bake git status -uno -b --porcelain)
    git_first_line=$(echo "$git_stat" | head -n 1)

    git_divergence=$(str_get_field "$git_first_line" 3)
    if str_matches "$git_divergence" 'ahead'; then
      echo "local git repository is ahead of remote"
      return $STATUS_CONFLICT_UPGRADE
    fi

    # are there changes?
    if str_matches "$git_stat" "^\\s?\\w"; then
      echo "local git repository has uncommitted changes"
      return $STATUS_CONFLICT_UPGRADE
    fi

    str_matches "$(str_get_field "$git_first_line" 2)" "$git_branch"
    if [ "$?" -ne 0 ]; then
      echo "local git repository is on incorrect branch"
      return $STATUS_MISMATCH_UPGRADE
    fi

    # If it's known to be behind, outdated
    if str_matches "$git_divergence" 'behind'; then return $STATUS_OUTDATED; fi

    # guess we're clean, so things are OK
    return $STATUS_OK ;;

  install)
    bake mkdir -p $git_dir
    bake git clone $git_url $git_dir
    ;;

  upgrade)
    bake cd $git_dir
    bake git reset --hard
    bake git pull
    bake git checkout $git_branch
    bake git log HEAD@{2}..
    printf "\n"
    ;;

  *) return 1 ;;
esac

