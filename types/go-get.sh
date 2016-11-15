action=$1
pkg=$2
shift 2

case $action in
    desc)
        echo "asserts a go pkg is installed in $GOPATH"
        echo "> go-get guru"
        ;;
    status)
        needs_exec "go" || return $STATUS_FAILED_PRECONDITION
        if ! bake go list $pkg> /dev/null 2>&1 ; then
            return $STATUS_MISSING
        fi
        return $STATUS_OK ;;
    install)
        bake go get -u "$pkg"
        ;;
esac
