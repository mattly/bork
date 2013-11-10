# Checks a list for a complete match
# pass: "foo bar bee" "foo"
# fail: "foo bar bee" "oo"
str_contains () {
  str_matches "$1" "^$2\$"
}

# Checks a string for any match. Accepts a regexp
# pass: "foo bar bee" "o{2,}\s+"
# fail: "foo bar bee" "ee\s+"
str_matches () {
  present=$(echo "$1" | grep -e "$2" > /dev/null)
  return $present
}

# Takes a string, replaces matches with a replacement
# "foo bar" "b\w+" "oo" -> "foo boo"
str_replace () {
  echo $(echo "$1" | sed -E 's|'"$2"'|'"$3"'|')
}


