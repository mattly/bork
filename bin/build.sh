#!/usr/bin/env bash

echo "#!/bin/bash"
cat lib/*.sh

for decl in declarations/*; do
  name=$(basename $decl .sh)
cat <<HERE
# ====== $decl: $name ==================================
bork_decl_$name () {
$(cat $decl)
}
$name () { pkg_runner 'bork_decl_$name' '$name' \$*; }
HERE
done

for pkg in packages/*.sh; do
  name=$(basename $pkg .sh)
cat <<HERE
# ======= $pkg: $name ==================================
bork_pkg_$name () {
$(cat $pkg)
}
HERE
done

echo "platform=\$(uname -s)"
echo "operation=\$1"
echo "\$bork_dir=\$PWD"
echo ". \$2"
