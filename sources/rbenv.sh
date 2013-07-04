rbenv () {
  if ! contains "$(command rbenv versions --bare )" $1; then
    bake "command rbenv install $1"
  fi
}


