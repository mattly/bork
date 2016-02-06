action=$1
name=$2
shift 2
pin=$(arguments get pin $*)

case $action in
    desc)
        echo "asserts a homebrew forumla repository has been tapped"
        echo "> brew-tap homebrew/games    (taps homebrew/games)"
        echo "--pin                        (pins the formula repository)"
    ;;

    status)
        baking_platform_is "Darwin" || return $STATUS_UNSUPPORTED_PLATFORM
        needs_exec "brew" || return $STATUS_FAILED_PRECONDITION
        list=$(bake brew tap)
        echo "$list" | grep -E "$name$" > /dev/null
        [ "$?" -gt 0 ] && return $STATUS_MISSING
        pinlist=$(bake brew tap --list-pinned)
        echo "$pinlist" | grep -E "$name$" > /dev/null
        pinstatus=$?
        if [ -n "$pin" ]; then
            [ "$pinstatus" -gt 0 ] && return $STATUS_PARTIAL
        else
            [ "$pinstatus" -eq 0 ] && return $STATUS_PARTIAL
        fi
        return $STATUS_OK ;;

    install)
        bake brew tap $name
        if [ -n "$pin" ]; then
            bake brew tap-pin $name
        fi
        ;;

    upgrade)
        if [ -n "$pin" ]; then
            bake brew tap-pin $name
        else
            bake brew tap-unpin $name
        fi
        ;;

    *) return 1 ;;
esac
