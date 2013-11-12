case $platform in
  Darwin)
    manager="brew"
    ;;
  *) bail "unknown Operating System $platform";;
esac

src_$manager $*
