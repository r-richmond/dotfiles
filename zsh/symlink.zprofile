
eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by Toolbox App
if [ -d "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" ]; then
  export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
fi
