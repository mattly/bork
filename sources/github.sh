github () {
  repo=$1
  dir=$(get_directory $2)
  if [ ! -d $dir ]; then
    c="mkdir -p $dir"
    c="$c && git clone --bare https://github.com/$(echo $repo).git $dir"
  else
    c="cd $dir && git pull"
  fi
  if [ -n "$c" ] ; then
    bake "$c"
  fi
}


