# keeps track of where we've come from
bag init include_directories
bag push include_directories "$BORK_SCRIPT_DIR"

include () {
    incl_script="$(bag read include_directories)/$1"
    if [ -e $incl_script ]; then
        target_dir=$(dirname $incl_script)
        bag push include_directories "$target_dir"
        case $operation in
            compile) compile_file "$incl_script" ;;
            *) . $incl_script ;;
        esac
        bag pop include_directories
    else
        echo "include: $incl_script: No such file" 1>&2
        exit 1
    fi
    return 0
}

