action=$1
target=$2
url=$3

case "$action" in
  desc)
    echo "assert presence of a downloaded file via curl"
    echo "> download "~/file.zip" \"http://server.com/file.zip\""
    ;;
  status)
    if bake [ -f \"$target\" ]; then
      existing_contentlength=$(ls -al "$target" | tr -s ' ' | cut -d' ' -f5)

      remote_contentlength=$(curl -sI "$url" | grep Content-Length | tr -s ' ' | cut -d' ' -f2)
      remote_contentlength=${remote_contentlength%%[^0-9]*} # remove all non-numerical characters

      if [ "$existing_contentlength" != "$remote_contentlength" ]; then
        echo "received Content-Length for existing file: $existing_contentlength bytes"
        echo "expected Content-Length from remote: $remote_contentlength bytes"
        return $STATUS_MISSING
      else
        return $STATUS_OK
      fi
    else
      return $STATUS_MISSING
    fi ;;

  install|upgrade)
    bake curl -so "$target" "$url" &> /dev/null ;;

  *) return 1;;
esac
