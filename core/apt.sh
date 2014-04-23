apt_cmd="sudo apt-get"
[ -n "$command_apt_get" ] && apt_cmd=$command_apt_get

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
    echo "$(bake dpkg --get-selections)" | grep -E "^$name\\s+install$"
    [ "$?" -gt 0 ] && return 10

    outdated=$(bake sudo apt-get -u update --dry-run \
                | grep "^Inst" | awk '{print $2}')
    $(str_contains "$outdated" "$name")
    [ "$?" -eq 0 ] && return 11
    return 0 ;;
  install|upgrade) bake sudo apt-get --yes install $name ;;
  *) return 1 ;;
esac

