functionize_thing () {
  name=$(basename $1 .sh)
  tmpfile=$(mktemp -t $name)
  echo "$name () {" > $tmpfile
  if [ "$2" = "--stub" ]; then
    cat $1 | while read line; do
      if [ "${line:0:4}" = "cmd=" ]; then echo "cmd='test_$name'" >> $tmpfile
      else echo $line >> $tmpfile
      fi
    done
  else
    cat $1 >> $tmpfile
  fi
  echo '}' >> $tmpfile
  . $tmpfile
  rm $tmpfile
}

