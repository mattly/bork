includes () {
  present=$(echo "$1" | grep -e "$2" > /dev/null)
  return $present
}

replace () {
  echo $(echo "$1" | sed -E 's/'"$2"'/'"$3"'/')
}

get_field () {
  echo $(echo "$1" | awk '{print $'"$2"'}')
}

get_directory () {
  echo $(eval "echo $1")
}

