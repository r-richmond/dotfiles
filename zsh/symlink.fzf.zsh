# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

# Auto-completion
# ---------------
source "/opt/homebrew/opt/fzf/shell/completion.zsh"

# Key bindings
# ------------
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"

# Show ISO timestamps and elapsed time in the Ctrl-R history picker.
fzf-history-widget() {
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases no_glob no_sh_glob no_ksharrays extendedglob 2> /dev/null

  selected="$(fc -rliD 1 | __fzf_exec_awk '{
    cmd=$0
    sub(/^[ \t]*[0-9]+\**[ \t]+[^ \t]+[ \t]+[^ \t]+[ \t]+[^ \t]+[ \t]+/, "", cmd)
    if (!seen[cmd]++) print $0
  }' |
    FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n5..,.. --scheme=history --bind=ctrl-r:toggle-sort,alt-r:toggle-raw --wrap-sign '\t↳ ' --highlight-line --multi ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER}") \
    FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  local ret=$?
  local -a cmds
  local -a mbegin mend match

  if [[ -n "$selected" ]]; then
    if [[ $selected == [[:blank:]]#<->(\*|)[[:blank:]]##[0-9]##-[0-9]##-[0-9]##[[:blank:]]##[0-9]##:[0-9]##[[:blank:]]##[^[:blank:]]##[[:blank:]]##* ]]; then
      for line in ${(ps:\n:)selected}; do
        if [[ $line == [[:blank:]]#(#b)(<->)(#B)(\*|)[[:blank:]]##[0-9]##-[0-9]##-[0-9]##[[:blank:]]##[0-9]##:[0-9]##[[:blank:]]##[^[:blank:]]##[[:blank:]]##* ]]; then
          zle .push-line
          zle vi-fetch-history -n ${match[1]}
          (( ${#BUFFER} )) && cmds+=("${BUFFER}")
          BUFFER=""
          zle .get-line
        fi
      done
      if (( ${#cmds[@]} )); then
        BUFFER="${(pj:\n:)${(@)cmds%%$'\n'#}}"
        CURSOR=${#BUFFER}
      fi
    else
      LBUFFER="$selected"
    fi
  fi

  zle reset-prompt
  return $ret
}

if [[ ${FZF_CTRL_R_COMMAND-x} != "" ]]; then
  zle     -N            fzf-history-widget
  bindkey -M emacs '^R' fzf-history-widget
  bindkey -M vicmd '^R' fzf-history-widget
  bindkey -M viins '^R' fzf-history-widget
fi
