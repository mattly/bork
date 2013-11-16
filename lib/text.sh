# Checks a list for a complete match
# pass: "foo bar bee" "foo"
# fail: "foo bar bee" "oo"
str_contains () {
  str_matches "$1" "^$2\$"
}

# retrieves the space-seperated field from a string
# str_get_field "foo bar bee" 2 -> "bar"
str_get_field () {
  echo $(echo "$1" | awk '{print $'"$2"'}')
}

# Counts the number of iteratable items in a string.
# Note that if the string is the output of a shell command, f.e:
#   dir_listing=$(ls)
# That you *must* quote the variable when passing it to the function:
#   str_item_count "$dir_listing"
# If you do not it will simply return '1'
str_item_count () {
  accum=0
  for item in $1; do
    ((accum++))
  done
  echo $accum
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


