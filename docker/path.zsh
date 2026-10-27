if [ -d "$HOME/.docker/completions" ]; then
  # The following lines have been added by Docker Desktop to enable Docker CLI completions.
  fpath=($HOME/.docker/completions $fpath)
  autoload -Uz compinit
  compinit
  # End of Docker CLI completions
fi

if [ -d "$HOME/.docker/bin" ]; then
  # The following lines were added by Docker Desktop to add commands to your PATH.
  export PATH="$PATH:$HOME/.docker/bin"
  # End of Docker Desktop section.
fi
