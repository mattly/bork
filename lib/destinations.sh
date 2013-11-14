bork_destinations=( )

destination () {
  (( last = ${#bork_destinations[*]} - 1 ))
  if [ -z "$1" ]; then
    current=${bork_destinations[$last]}
    [ -z "$current" ] && echo $PWD || echo $current
  else
    case "$1" in
      clear) bork_destinations=( ) ;;
      pop) unset bork_destinations[$last] ;;
      push) bork_destinations[$last+1]=$2 ;;
      size) echo ${#bork_destinations[*]} ;;
      *) return 1 ;;
    esac
  fi
}
