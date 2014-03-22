bork_destinations_root=$PWD
bork_destinations=( )

destination () {
  (( last = ${#bork_destinations[*]} - 1 ))
  if [ -z "$1" ]; then
    if [ $last -eq -1 ]; then echo $bork_destinations_root
    else echo ${bork_destinations[$last]}
    fi
  else
    case "$1" in
      clear)
        bork_destinations=( )
        cd $(destination)
        ;;
      pop)
        unset bork_destinations[$last]
        stat=$?
        cd $(destination)
        return $stat
        ;;
      push)
        bork_destinations[$last+1]=$2
        cd $2
        ;;
      size) echo ${#bork_destinations[*]} ;;
      *) return 1 ;;
    esac
  fi
}
