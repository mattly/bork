rbenv () {
  if ! includes "$(command rbenv versions --bare )" $1; then
    echo $(command rbenv install $1)
  fi
}


