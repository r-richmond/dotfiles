#!/usr/bin/env bash

# manual rsync for terminal themes
rsync -avh --no-perms --exclude "install.sh" "$DOTFILES"/macos/terminal_themes ~/;
