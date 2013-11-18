action=$1
url=$2
shift 2

bork_src_git $action "https://github.com/$(echo $url).git" $*

