bag init baking_values
bake () {
  case $1 in
    dir) bag set baking_values dir $2 ;;
    user) bag set baking_values user $2 ;;
    sudo) bag set baking_values sudo $2 ;;
    reset) bag init baking_values ;;
    *)
      bake_cmd=

      dir=$(bag get baking_values dir)
      [ -n "$dir" ] && bake_cmd+="cd $dir && "

      user=$(bag get baking_values user)
      sudo=$(bag get baking_values sudo)
      if [ -n "$sudo" ]; then
        bake_cmd+="sudo sh -c '$1'"
      elif [ -n "$user" ]; then
        bake_cmd+="sudo -u $user -c '$1'"
      else
        bake_cmd+="$1"
      fi

      (eval $bake_cmd)
    ;;
  esac
}


