multiline () {
  action=$1
  varname=$2
  shift 2
  case $action in
    init)
      eval "${!varname}="
      ;;
    add)
      echo ${!varname}
      echo $1
      ;;
    find)
      match=$(echo "${!varname}" | while read line; do
        if str_matches "$line" "$1"; then
          echo "$line"
          return 0
        fi
      done)
      [ -z "$match" ] && return 1
      echo "$match"
      ;;
    key)
      match=$(multiline find $varname "^$1=")
      [ "$?" -gt 0 ] && return 1
      echo "${match##*=}"
      ;;
    *) return 1 ;;
  esac
}
