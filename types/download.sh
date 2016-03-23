action=$1
targetfile=$2
sourceurl=$3
shift 3

case "$action" in
    desc)
        echo "assert the presence & comparisons of a file to a URL"
        echo "> download ~/file.zip \"http://example.com/file.zip\""
        echo "--size                (compare size to Content-Length at URL)"
        ;;

    status)
        bake [ -f "\"$targetfile\"" ] || return $STATUS_MISSING

        if $(arguments get size); then
            fileinfo=$(bake ls -al "\"$targetfile\"")
            sourcesize=$(echo "$fileinfo" | tr -s ' ' | cut -d' ' -f5)
            remoteinfo=$(bake $(http_head_cmd "$sourceurl"))
            remotesize=$(http_header "Content-Length" "$remoteinfo")
            remotesize=${remotesize%%[^0-9]*}
            if [ "$sourcesize" != "$remotesize" ]; then
                echo "expected size: $remotesize bytes"
                echo "received size: $localsize bytes"
                return $STATUS_CONFLICT_UPGRADE
            fi
        fi
        return $STATUS_OK
    ;;

    install|upgrade)
        bake $(http_get_cmd "$sourceurl" "$targetfile")
    ;;

    *) return 1 ;;
esac
