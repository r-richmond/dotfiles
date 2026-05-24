export STARSHIP_CONFIG="$DOTFILES/shell_prompts/starship_standard/starship.toml"

_starship_standard_format_cmd_duration() {
  emulate -L zsh

  local duration_ms="${1:-0}"
  local total seconds millis minutes

  [[ "$duration_ms" == <-> ]] || duration_ms=0
  total=$duration_ms

  if (( total < 1000 )); then
    printf '%dms' "$total"
  elif (( total < 10000 )); then
    seconds=$(( total / 1000 ))
    millis=$(( total % 1000 ))
    printf '%d.%03ds' "$seconds" "$millis"
  elif (( total < 60000 )); then
    seconds=$(( total / 1000 ))
    printf '%ds' "$seconds"
  else
    minutes=$(( total / 60000 ))
    seconds=$(( (total % 60000) / 1000 ))
    printf '%d:%02d' "$minutes" "$seconds"
  fi
}

_starship_standard_set_command_duration() {
  emulate -L zsh

  local duration_ms="${STARSHIP_DURATION:-0}"

  export STARSHIP_COMMAND_DURATION="$(_starship_standard_format_cmd_duration "$duration_ms")"
}

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _starship_standard_set_command_duration
fi
