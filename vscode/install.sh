#!/usr/bin/env bash

set -e

DOTFILES_ROOT="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"

backup_file () {
  local dst=$1 print=$2
  local backup_root="$HOME/backup-dot-files"
  local backup_path="$backup_root$dst"
  local backup_dir

  backup_dir=$(dirname "$backup_path")
  mkdir -p "$backup_dir"

  if [ -e "$backup_path" ] || [ -L "$backup_path" ]; then
    backup_path="$backup_path.$(date +%Y%m%d%H%M%S)"
  fi

  mv "$dst" "$backup_path"
  if [ "$print" = "true" ]; then
    echo "moved $dst to $backup_path"
  fi
}

setup_file () {
  local src=$1 dst=$2

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    return 0
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    backup_file "$dst" "true"
  fi

  ln -s "$src" "$dst"
}

# Configure settings_directory by platform
if [ "$(uname -s)" = "Darwin" ]; then
  settings_directory="$HOME/Library/Application Support/Code/User"
else
  echo 'Unsure where to install on non-macos platforms'
  echo 'Please edit ./vscode/install.sh'
  # settings_directory=???
  echo '-----VSCODE configuration NOT COMPLETE----'
  exit 1
fi

mkdir -p "$settings_directory"

setup_file "$DOTFILES_ROOT/vscode/settings.json" "$settings_directory/settings.json"
setup_file "$DOTFILES_ROOT/vscode/keybindings.json" "$settings_directory/keybindings.json"

# Install vscode extensions
# http://evanhahn.com/atom-apm-install-list/
if ! command -v code >/dev/null 2>&1; then
  echo 'VS Code command-line tool not found; skipping extension install'
  exit 0
fi

# shellcheck disable=SC1091
source "$DOTFILES_ROOT/functions/code-extension"
code-extension install-all

exit 0