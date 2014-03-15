#!/usr/bin/env bash

echo "#!/bin/bash"
cat lib/*.sh

for decl in declarations/*; do
  name=$(basename $decl .sh)
cat <<HERE
# ====== declaration $decl: $name ======================
bork_decl_$name () {
$(cat $decl)
}
$name () { pkg_runner 'bork_decl_$name' '$name' \$*; }
HERE
done

for pkg in packages/*.sh; do
  name=$(basename $pkg .sh)
cat <<HERE
# ======= package $pkg: $name ==========================
bork_pkg_$name () {
$(cat $pkg)
}
HERE
done

cat <<HERE
platform=\$(uname -s)
operation=\$1

bork_dir="\$PWD"
if str_matches "\$2" "^/"; then bork_script_dir="\$2"
else
  #TODO extract this to a helper
  _fullPath="\$(pwd -P)/\$2"
  _fullDir="\$(dirname \$_fullPath)"
  bork_script_dir="\$(cd \$_fullDir; echo \$PWD)"
fi

. \$2
HERE
