#!/usr/bin/env bash
#
# Homebrew Installation

set -e

DOTFILES_ROOT="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"

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

download_font() {
  local url=$1
  local output=$2

  curl -fsSL "$url" --output "$output"
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
brew bundle --file="$DOTFILES_ROOT/homebrew/universal_cli.brewfile"

# install universal casks on mac
if [ "$(uname -s)" = "Darwin" ]; then
  brew bundle --file="$DOTFILES_ROOT/homebrew/universal_cask.brewfile"

  echo " - Install personal casks? (y/n) "
  read -r -n 1 answer
  echo ''
  if [ "$answer" != "${answer#[Yy]}" ]; then
    echo '  Installing personal casks...' # new line
    brew bundle --file="$DOTFILES_ROOT/homebrew/personal_cask.brewfile"
  fi

  # finalize some brew installs
  mkdir -p "$HOME/Library/Fonts"
  download_font 'https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Regular.ttf' "$HOME/Library/Fonts/MesloLGS NF Regular.ttf"
  download_font 'https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold.ttf' "$HOME/Library/Fonts/MesloLGS NF Bold.ttf"
  download_font 'https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Italic.ttf' "$HOME/Library/Fonts/MesloLGS NF Italic.ttf"
  download_font 'https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold%20Italic.ttf' "$HOME/Library/Fonts/MesloLGS NF Bold Italic.ttf"
fi

exit 0
