#!/usr/bin/env bash

set -e

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"
export DOTFILES

# If its mac install workflows & Library configs
if [ "$(uname -s)" = "Darwin" ]; then
  mkdir -p "$HOME/Library"
  rsync --exclude "README.md" \
    --exclude ".DS_Store" \
    --exclude "install.sh" \
    -ah --no-perms "$DOTFILES/library/" "$HOME/Library/"
else
  echo 'On Linux not Running Library/install.sh'
fi

exit 0
