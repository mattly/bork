md5cmd () {
  case $1 in
    Darwin)
      [ -z "$2" ] && echo "md5" || echo "md5 -q $2"
      ;;
    Linux)
      [ -z "$2" ] && arg="" || arg="$2 "
      echo "md5sum $arg| awk '{print \$1}'"
      ;;
    *) return 1 ;;
  esac
}

