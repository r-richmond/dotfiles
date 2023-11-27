ThingsToSource=( # Some zsh completiton scripts that may or may not exist
  "/Users/$USER/.docker/init-zsh.sh" # Added by Docker Desktop
)

for file in "${ThingsToSource[@]}"; do
  if [[ -f "$file" ]]; then
    source "$file"
  fi
done
