. bin/bork load

here=$PWD
debug_mode="$DEBUG"
p () {
  [ -n "$debug_mode" ] && echo "$@" >> "$here/debug"
  return 0
}

md5c=$(md5cmd $platform)
baking_responder=
baking_file=$(mktemp -t bork_test.XXXXXX)
bake () {
  echo "$@" >> $baking_file;
  key=$(echo "$@" | eval $md5c)
  handler=$(bag get responders $key)
  p "looking up $@ at $key, found $handler"
  if [ -n "$handler" ]; then
    eval $handler
  else
    baking_responder "$@"
  fi
  return
}
# overwrite this in your tests
baking_responder () { :; }

baked_output () { cat $baking_file; }

fixtures="$BORK_SOURCE_DIR/test/fixtures"

bag init responders
respond_to () {
  key=$(echo "$1" | eval $md5c)
  p "setting $1 at $key"
  bag set responders "$key" "$2"
}
return_with () { return $1; }

