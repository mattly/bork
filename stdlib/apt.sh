apt_cmd="command sudo apt-get"
if [ -n $command_apt_get ]; then apt_cmd=$command_apt_get; fi
apt_outdated_cmd="$apt_cmd -u upgrade --dry-run"
if [ -n $command_apt_outdated ]; then apt_outdated_cmd=$command_apt_outdated; fi
apt_list_cmd="command dpkg --get-selections"
if [ -n $command_apt_list ]; then apt_list_cmd=$command_apt_list; fi

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
    $(str_contains "$($apt_list_cmd | awk '{print $1}')" "$name")
    [ "$?" -gt 0 ] && return 10
    $(str_contains "$($apt_outdated_cmd | grep "^Inst" | awk '{print $2}')" "$name")
    [ "$?" -eq 0 ] && return 11
    return 0 ;;
  install) bake "$apt_cmd --yes install $name" ;;
  upgrade) bake "$apt_cmd --yes install $name" ;;
  *) return 1 ;;
esac
