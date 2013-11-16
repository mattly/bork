for f in $(ls lib/*.sh); do . $f; done

functionize_thing () {
  name=$(basename $1 .sh)
  tmpfile=$(mktemp -t $name)
  echo "$name () {" > $tmpfile
  cat $1 | while read line; do
    if [ "${line:0:4}" = "cmd=" ]; then echo "cmd='test_$name'" >> $tmpfile
    else echo $line >> $tmpfile
    fi
  done
  echo '}' >> $tmpfile
  . $tmpfile
  rm $tmpfile
}

baking_file=$(mktemp -t bork_test)
bake () { echo "$*" >> $baking_file; }
baked_output () { cat $baking_file; }

here=$PWD
debug_mode="$DEBUG"
p () {
  [ -n "$debug_mode" ] && echo "$*" >> "$here/debug"
  return 0
}
