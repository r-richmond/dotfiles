#!/usr/bin/env bash

set -e

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)}"
export DOTFILES

if [ "$(uname -s)" != "Darwin" ]; then
	exit 0
fi

# manual rsync for terminal themes
rsync -ah --no-perms --exclude "install.sh" "$DOTFILES/macos/terminal_themes/" "$HOME/"
