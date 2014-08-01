# TODO tests
action=$1
app=$2
app_id=$3
shift 3

case $action in
  desc)
    echo "asserts a Mac app is installed in /Applications, if not asks to install from Mac App Store"
    echo "* macstore AppName id"
    echo "  (id can be extracted from app store URL)"
    echo "> macstore Tweetbot 557168941"
    ;;
  status)
    [ -d "/Applications/$app.app" ] && return $STATUS_OK || return $STATUS_MISSING
    ;;
  install)
    bake open "macappstore://itunes.apple.com/app/id$app_id?mt=12"
    read -p "Press a Key when $app is installed from the Mac App Store:"
esac
