#!/usr/bin/env bash

set -e

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"
export DOTFILES

if [ "$(uname -s)" != "Darwin" ]; then
  exit 0
fi

# The Brewfile handles Homebrew-based app and library installs, but there may
# still be updates and installables in the Mac App Store. There's a nifty
# command line interface to it that we can use to just install everything, so
# yeah, let's do that.

echo "› sudo softwareupdate -i -a"
sudo softwareupdate -i -a

# find default settings for mac apps and run them iteratively
while IFS= read -r -d '' installer; do
  echo "Running ${installer}"
  bash "$installer"
done < <(find "$DOTFILES/macos" -maxdepth 1 -type f -name 'defaults-*.sh' -print0)
