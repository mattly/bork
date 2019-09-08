action=$1
shell=$2
shift 2

current_shell () {
    case $platform in
        Darwin) echo "$(dscl localhost -read /Local/Default/Users/"$USER" shell|grep -oE '[^ ]+$')" ;;
        *) echo "$(getent passwd "$USER" | awk -F : '{print $NF}')" ;;
    esac
}

case $action in
desc)
    echo "asserts current user's login shell"
    echo "* shell /bin/zsh        (sets current shell)"
    ;;
status)
    [ "$(bake current_shell)" = $shell ] && return $STATUS_OK
    return $STATUS_MISSING
    ;;

install)
    bake "chsh -s $shell"
    ;;

*) return 1 ;;
esac
