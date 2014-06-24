bork_using_tmpdir=

use_tmpdir () {
  [ -n "$bork_using_tmpdir" ] && return 1
  tmpdirname="borky"
  [ -n $bork_operation ] && tmpdirname=$bork_operation
  [ -n $1 ] && tmpdirname=$1
  bork_using_tmpdir=$(mktemp -d -t "$tmpdirname"".XXXX")
  destination push $bork_using_tmpdir
}

clean_tmpdir () {
  [ -z "$bork_using_tmpdir" ] && return 0
  destination pop
  rm -rf $bork_using_tmpdir
  bork_using_tmpdir=
}

