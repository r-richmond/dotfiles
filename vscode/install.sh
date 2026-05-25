#!/usr/bin/env bash

set -e

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"
export DOTFILES

# Install vscode extensions
# http://evanhahn.com/atom-apm-install-list/
if ! command -v code >/dev/null 2>&1; then
  echo 'VS Code command-line tool not found; skipping extension install'
  exit 0
fi

# shellcheck disable=SC1091
source "$DOTFILES/functions/code-extension"
code-extension install-all

exit 0
