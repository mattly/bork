BORK_WORKING_DIR=$PWD
BORK_SOURCE_DIR=$PWD
BORK_SCRIPT_DIR=$PWD

here=$PWD
debug_mode="$DEBUG"
p () {
  [ -n "$debug_mode" ] && echo "$*" >> "$here/debug"
  return 0
}

for f in $(ls lib/*.sh); do . $f; done

baking_responder=
baking_file=$(mktemp -t bork_test)
bake () {
  echo "$*" >> $baking_file;
  key=$(echo "$*" | md5)
  handler=$(bag get responders $key)
  if [ -n "$handler" ]; then
    eval $handler
  elif [ -n "$baking_responder" ]; then
    $baking_responder $*
  fi
  return
}
bake_in () { echo "bake_in $*" >> $baking_file; }
baked_output () { cat $baking_file; }

fixtures="$BORK_SOURCE_DIR/test/fixtures"

bag init responders
respond_to () {
  key=$(echo "$1" | md5)
  bag set responders "$key" "$2"
}
return_with () { return $1; }

