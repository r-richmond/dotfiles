# https://kubernetes.io/docs/tasks/tools/install-kubectl/
ThingsToSource=( # Some zsh completiton scripts that may or may not exist
  "$(brew --prefix)/bin/kubectl"
)

for file in "${ThingsToSource[@]}"; do
  if [[ -f "$file" ]]; then
    source <("$file" completion zsh)
  fi
done
