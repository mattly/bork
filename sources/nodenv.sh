nodenv () {
  if ! includes "$(command nodenv versions --bare )" $1; then
    echo $(command nodenv install $1)
  fi
}

