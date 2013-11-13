bork_destinations=( )

destination () {
  (( last = ${#bork_destinations[*]} - 1 ))
  if [ -z "$1" ]; then
    current=${bork_destinations[$last]}
    [ -z "$current" ] && echo $PWD || echo $current
  else
    case "$1" in
      push)
        bork_destinations[$last+1]=$2
        ;;
      pop)
        unset bork_destinations[$last]
        ;;
    esac
  fi
}
