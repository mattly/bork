bork_destinations=( )

destination () {
  len=${#bork_destinations[@]}
  current=${bork_destinations[$len-1]}
  [ -z "$current" ] && echo $PWD || echo $current
}

destination_push () {
  bork_destinations[${#bork_destinations[*]}]=$1
}

destination_pop () {
  unset bork_destinations[${#bork_destinations[*]}-1]
}
