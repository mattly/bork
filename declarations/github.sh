action=$1
url=$2
shift 2

bork_decl_git $action "https://github.com/$(echo $url).git" $*

