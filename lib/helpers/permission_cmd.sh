permission_cmd () {
  case $1 in
    Linux) echo "stat --printf '%a'" ;;
    Darwin) echo "stat -f '%Lp'" ;;
    *) return 1 ;;
  esac
}
