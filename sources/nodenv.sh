nodenv () {
  if ! contains "$(command nodenv versions --bare )" $1; then
    bake "command nodenv install $1"
  fi
}

