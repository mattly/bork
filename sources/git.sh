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
    fetch=$(cd $dir
            command git fetch --dry-run)
    if [ -n "$fetch" ]; then
      bake_at $dir
      bake "command git pull"
      bake_at $dir
      bake "command git log HEAD@{1}.."
    fi
  fi
}
