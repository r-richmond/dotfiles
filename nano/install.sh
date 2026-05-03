#!/usr/bin/env bash

set -e

nano_dir="$HOME/.nano"

if ! command -v git >/dev/null 2>&1; then
  echo 'git is required for nano/install.sh'
  exit 1
fi

if [ -e "$nano_dir" ] && [ ! -d "$nano_dir/.git" ]; then
  echo "$nano_dir exists but is not a git repository"
  exit 1
fi

if [ ! -d "$nano_dir" ]; then
  echo "Cloning fantastic nano syntax repo"
  git clone https://github.com/scopatz/nanorc "$nano_dir"
fi

# Manual Updates
git -C "$nano_dir" pull --quiet
