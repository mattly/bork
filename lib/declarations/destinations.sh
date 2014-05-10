bag init bork_destinations

destination () {
  if [ -z "$1" ]; then
    current=$(bag read bork_destinations)
    [ -n "$current" ] && echo $current || echo $BORK_WORKING_DIR
  else
    case "$1" in
      clear)
        bag init bork_destinations
        cd $(destination)
        ;;
      pop)
        bag pop bork_destinations
        cd $(destination)
        ;;
      push)
        bag push bork_destinations $2
        cd $2
        ;;
      size) echo $(bag size bork_destinations) ;;
      *) return 1 ;;
    esac
  fi
}
