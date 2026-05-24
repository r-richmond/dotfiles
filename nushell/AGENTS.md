# Nushell Configuration

Only `symlinkLibrary+Application Support+nushell+config.nu` is installed as the managed Nushell config symlink. That file stays small and sources the rest of this directory from the real `$nu.config-path`, so local modules can live in the repo without each one being symlinked into `~/Library/Application Support/nushell`.

## Files

- `symlinkLibrary+Application Support+nushell+config.nu`: entrypoint loaded by Nu. Resolves this directory and sources `history.nu`, `hotkeys.nu`, and the shared Starship prompt in `../shell_prompts/starship_standard/prompt.nu`.
- `history.nu`: native history settings plus an enhanced JSONL history used by the fzf picker. It records command, duration, cwd, git repo, and git branch, while suppressing only consecutive duplicate commands.
- `hotkeys.nu`: interactive keybindings. Currently binds `ctrl-r` in emacs and vi modes to the enhanced fzf history picker.
- `symlinkLibrary+Application Support+nushell+env.nu`: generated compatibility file loaded by Nu before `config.nu`; currently intentionally empty apart from Nu's default comments.

Shared prompt files live outside this folder:

- `../shell_prompts/starship_standard/prompt.nu`: Starship/Nushell prompt integration. It sets `STARSHIP_CONFIG`, installs left and right prompt closures, and formats command duration for Starship.
- `../shell_prompts/starship_standard/starship.toml`: Starship prompt layout and styling for cwd, git, language tools, duration, cloud/IP info, and timestamp.

## Sourced Helpers

These files are sourced into the interactive Nu scope rather than imported as modules, so helper names are available after startup:

- `_nu-fzf-history`: opens the enhanced command history in `fzf` and inserts the selected command into the commandline.
- `_nu-git-history-context`: returns git repo and branch metadata for a cwd, used by the history hooks.
- `_nu-enhanced-history-records`: reads enhanced history JSONL and returns display-ready records.
- `_nu-enhanced-history-rows`: formats enhanced history records for `fzf`.
- `_starship-format-cmd-duration`: formats command duration for the prompt, keeping milliseconds only below 10 seconds.
