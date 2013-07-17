git () {
  git_url=$1
  dir=$2
  if [ -z $dir ]; then
    repo_name=$(basename $1 .git)
    dir="$current_destination/$repo_name"
  fi
  if [ ! -d $dir ]; then
    bake "mkdir -p $dir"
    bake "command git clone $git_url $dir"
  else
    echo $git_url
    fetch=$(cd $dir; command git fetch --dry-run 2>&1 )
    if matches "$fetch" "\s\+[a-f0-9]\{7\}\.\.[a-f0-9]\{7\}" ; then
      echo "$fetch"
      git_update "$dir" "$git_url"
      return 0
    fi
    status=$(cd $dir; command git status )
    if matches "$status" "Your branch is behind" ; then
      git_update "$dir" "$git_url"
    fi
  fi
}

git_update () {
  [ -n "$2" ] && echo "updating $2"
  bake_at $1
  bake "command git pull"
  bake_at $1
  bake "command git log HEAD@{1}.."
}
