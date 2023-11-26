ThingsToSource=( # Some zsh completiton scripts that may or may not exist
  "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"       # installed by brew cask install google-cloud-sdk
  "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc" # installed by brew cask install google-cloud-sdk
)

for file in "${ThingsToSource[@]}"; do
  if [[ -f "$file" ]]; then
    echo "Sourcing $file"
    source "$file"
  fi
done
