# are we running from a compiled script?
is_compiled () { return 1; }

for file in $BORK_SOURCE_DIR/lib/helpers/*.sh \
            $BORK_SOURCE_DIR/lib/declarations/*.sh;
do
  . $file
done
