. bin/bork load
BORK_SCRIPT_DIR=$PWD

here=$PWD
debug_mode="$DEBUG"
p () {
  [ -n "$debug_mode" ] && echo "$*" >> "$here/debug"
  return 0
}

baking_responder=
baking_file=$(mktemp -t bork_test)
bake () {
  echo "$*" >> $baking_file;
  key=$(echo "$*" | md5)
  handler=$(bag get responders $key)
  if [ -n "$handler" ]; then
    eval $handler
  else
    baking_responder $*
  fi
  return
}
# overwrite this in your tests
baking_responder () { :; }

baked_output () { cat $baking_file; }

fixtures="$BORK_SOURCE_DIR/test/fixtures"

bag init responders
respond_to () {
  key=$(echo "$1" | md5)
  bag set responders "$key" "$2"
}
return_with () { return $1; }

