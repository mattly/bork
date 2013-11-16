arguments () {
  op=$1
  shift
  case $op in
    get)
      key=$1
      shift
      value=
      while [ -n "$1" ] && [ -z "$value" ]; do
        this=$1
        shift
        if [ ${this:0:2} = '--' ]; then
          tmp=${this:2}       # strip off leading --
          param=${tmp%%=*}    # everything before =
          val=${tmp##*=}      # everything after =
          if [ "$param" = $key ]; then value=$val; fi
        fi
      done
      [ -n $value ] && echo "$value"
      ;;
    *) return 1 ;;
  esac
}
