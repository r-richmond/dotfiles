#!/usr/bin/env bash

set -e

DOTFILES_ROOT="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)}"

if [ "$(uname -s)" != "Darwin" ]; then
	exit 0
fi

# manual rsync for terminal themes
rsync -ah --no-perms --exclude "install.sh" "$DOTFILES_ROOT/macos/terminal_themes/" "$HOME/"
