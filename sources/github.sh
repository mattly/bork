github () {
  repo=$1
  dir=$(get_directory $2)
  if [ ! -d $dir ]; then
    echo mkdir -p $dir
    c="git clone --bare https://github.com/$(echo $repo).git $dir"
  else
    c="cd $dir && git pull"
  fi
  if [ -n "$c" ] ; then echo $c ; fi
}


