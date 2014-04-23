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
  [ -n "$baking_responder" ] && $baking_responder $*
  return
}
bake_in () { echo "bake_in $*" >> $baking_file; }
baked_output () { cat $baking_file; }

fixtures="$BORK_SOURCE_DIR/test/fixtures"

