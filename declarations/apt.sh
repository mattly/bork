apt_cmd="command sudo apt-get"
outdated_cmd="$apt_cmd -u upgrade --dry-run"
list_cmd="command dpkg --get-selections"

bork_valid_setup () {
  echo "apt_cmd"
  echo "list_cmd"
  echo "outdated_cmd"
}
bork_setup_apt () {
  (str_contains "$(bork_valid_setup)" "$1")
  stat=$?
  [ "$stat" -gt 0 ] && return 1
  eval "$1=$2"
}

bork_decl_apt () {
  action=$1
  name=$2
  shift 2
  case $action in
    depends)
      echo "platform: Linux"
      echo "exec: apt-get"
      echo "exec: dkpg"
      ;;
    status)
      $(str_contains "$($list_cmd | awk '{print $1}')" "$name")
      [ "$?" -gt 0 ] && return 10
      $(str_contains "$($outdated_cmd | grep "^Inst" | awk '{print $2}')" "$name")
      [ "$?" -eq 0 ] && return 11
      return 0 ;;
    install)
      bake "$apt_cmd --yes install $name" ;;
    *) return 1 ;;
  esac
}
declare_source "apt" "bork_decl_apt"
