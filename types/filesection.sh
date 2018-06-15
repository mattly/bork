action=$1
targetfile=$2
sourcefile=$3
shift 3

start=$(arguments get start "$@")
end=$(arguments get end "$@")
ifmissing=$(arguments get ifmissing "$@")

startre='/^'"${start/\//\\\//}"'\s*$/'
endre='/^'"${end/\//\\\//}"'\s*$/'

file_varname="borkfiles__$(echo "$sourcefile" | base64 | sed -E 's|\+|_|' | sed -E 's|\?|__|' | sed -E 's|=+||')"

read_files() {
    if ! is_compiled && [ ! -f $sourcefile ]; then
      echo "source file doesn't exist: $sourcefile"
      return $STATUS_FAILED_ARGUMENTS
    fi

    bake [ -f $targetfile ] || return $STATUS_MISSING

    # TODO: need to distinguish local platfrom from target platform
    if is_compiled; then
      sourcecontents=$(echo "${!file_varname}" | base64 --decode; echo END)
    else
      sourcecontents=$(cat $sourcefile; echo END)
    fi
    sourcecontents=${sourcecontents%END}

echo "start: $start"
echo "end: $end"
echo "startre: $startre"
echo "endre: $endre"

    startline=$(bake sed -ne "${startre}=" $targetfile)
    endline=$(bake sed -ne "${endre}=" $targetfile)

echo "startline: $startline"
echo "endline: $endline"

    if [ "$startline" != "" ] && [ "$endline" != "" ] && (( startline < endline - 1 ));
 then
      targetcontents=$(bake sed -ne "$((startline + 1))","$((endline - 1))"' p' $targetfile; echo END)
      targetcontents=${targetcontents%END}
    else
      targetcontents=""
    fi
}

case $action in
  desc)
    echo "replaces a section of a file with the source file"
    echo "* filesection target-path source-path [arguments]"
    echo "--start='# Managed, DO NOT EDIT'    line to start with"
    echo "--end='# End Managed'               line to end with"
    echo "--ifmissing=append|prepend|nothing  if section is missing, do this"
    ;;

  status)
    read_files || return $?

    if [ "$startline" == "" ] && [ "$endline" == "" ]; then
      echo "section missing"
      echo "action: $ifmissing"
      return $STATUS_MISSING
    fi

    if [ "$startline" == "" ] || [ "$endline" == "" ]; then
      echo "$targetfile has start($startline) or end($endline), but not both"
      echo "please fix"
      return $STATUS_FAILED
    fi

    if [ "$targetcontents" != "$sourcecontents" ]; then
      echo "expected: $sourcecontents"
      echo "received: $targetcontents"
      return $STATUS_CONFLICT_UPGRADE
    fi

    return 0
    ;;

  install|upgrade)
    read_files || return $?

    if [ "$startline" == "" ] && [ "$endline" == "" ]; then
      case "$ifmissing" in
      append)
        printf "%s\n%s%s\n" "$start" "$sourcecontents" "$end" >> $targetfile
        return 0
        ;;
      prepend)
        targetfullcontents=$(cat $targetfile; printf "END")
        targetfullcontents=${targetfullcontents%END}

        printf "%s\n%s%s\n%s" "$start" "$sourcecontents" "$end" "$targetfullcontents" > $targetfile
        return 0
        ;;
      *)
        echo "Unknown ifmissing: $ifmissing"
        return $STATUS_FAILED_ARGUMENTS
      esac
    fi

    if [ "$startline" == "" ] || [ "$endline" == "" ]; then
      echo "section has start or end, but not both"
      echo "please fix"
      return $STATUS_FAILED
    fi

    if (( startline < endline - 1 )); then
      deletecontents="$((startline + 1)),$((endline - 1)) d"
    else
      deletecontents=""
    fi

    bake sed -e "
      $startline r "<(echo -n "$sourcecontents")"
      $deletecontents
    " --in-place $targetfile

    return $?
    ;;

  compile)
    if [ ! -f "$sourcefile" ]; then
      echo "fatal: file '$sourcefile' does not exist!" 1>&2
      exit 1
    fi
    if [ ! -r "$sourcefile" ]; then
      echo "fatal: you do not have read permission for file '$sourcefile'"
      exit 1
    fi
    echo "# source: $sourcefile"
    echo "# md5 sum: $(eval $(md5cmd $platform $sourcefile))"
    echo "$file_varname=\"$(cat $sourcefile | base64)\""
    ;;

  *) return 1 ;;
esac

