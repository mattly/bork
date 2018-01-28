bake () {
  C=''
  for i in "$@"; do
      case "$i" in
          *\'*)
              i=`printf "%s" "$i" | sed "s/'/'\"'\"'/g"`
              ;;
          *) : ;;
      esac
      C="$C '$i'"
  done
  eval "$C"
}
