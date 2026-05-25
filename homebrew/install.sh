#!/usr/bin/env bash
#
# Homebrew Installation

set -e

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"
export DOTFILES

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  command -v brew >/dev/null 2>&1
}

# Check for Homebrew
if ! ensure_brew; then
  echo "  Installing Homebrew for you."

  if ! command -v curl >/dev/null 2>&1; then
    echo 'curl is required to install Homebrew'
    exit 1
  fi

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ensure_brew || {
    echo 'brew was not found after Homebrew installation'
    exit 1
  }
fi

# Turn off brew analytics
brew analytics off

# shellcheck disable=SC1091
source "$DOTFILES/functions/brew-extension"
brew-extension task

exit 0
