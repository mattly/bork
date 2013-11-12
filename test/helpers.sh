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
