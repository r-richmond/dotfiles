export PATH="/opt/homebrew/bin:$PATH"

# this makes core utls available in path
export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"

# this sets ggrep as grep
export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"

# this sets gsed as sed
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"

# Homebrew will now attempt to upgrade casks with `auto_updates true`.
# Disable this behaviour with `HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS=1`.
# Some casks with `auto_updates true` or `version :latest` may still require `--greedy`,
# `HOMEBREW_UPGRADE_GREEDY` or `HOMEBREW_UPGRADE_GREEDY_CASKS` to be upgraded.
export HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS=1
