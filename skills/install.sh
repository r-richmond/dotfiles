#!/usr/bin/env bash

set -euo pipefail

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"
export DOTFILES

SKILLS_ROOT="$DOTFILES/skills/symlink.agents+skills"
SOURCES_FILE="$DOTFILES/skills/sources.txt"

require_command() {
  local command_name=$1

  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'missing required command: %s\n' "$command_name" >&2
    exit 1
  fi
}

sync_git_directory() {
  local target_name=$1
  local repo_url=$2
  local ref=$3
  local source_path=$4
  local temp_root repo_dir source_dir target_dir

  temp_root=$(mktemp -d)
  repo_dir="$temp_root/repo"
  target_dir="$SKILLS_ROOT/$target_name"

  git clone --quiet --filter=blob:none --no-checkout "$repo_url" "$repo_dir"
  git -C "$repo_dir" sparse-checkout init --no-cone >/dev/null
  git -C "$repo_dir" sparse-checkout set "$source_path" >/dev/null
  git -C "$repo_dir" checkout --quiet "$ref"

  source_dir="$repo_dir/$source_path"
  if [ ! -d "$source_dir" ]; then
    printf 'missing source path for %s: %s (%s @ %s)\n' "$target_name" "$source_path" "$repo_url" "$ref" >&2
    rm -rf "$temp_root"
    exit 1
  fi

  mkdir -p "$target_dir"
  rsync -a --delete --exclude '.git/' "$source_dir/" "$target_dir/"
  rm -rf "$temp_root"
}

install_sources() {
  local line target_name repo_url ref source_path

  while IFS= read -r line || [ -n "$line" ]; do
    [ -n "$line" ] || continue
    case "$line" in
    \#*)
      continue
      ;;
    esac

    IFS='|' read -r target_name repo_url ref source_path <<<"$line"

    if [ -z "$target_name" ] || [ -z "$repo_url" ] || [ -z "$ref" ] || [ -z "$source_path" ]; then
      printf 'invalid skills source entry: %s\n' "$line" >&2
      exit 1
    fi

    printf ' syncing %s\n' "$target_name"
    sync_git_directory "$target_name" "$repo_url" "$ref" "$source_path"
  done <"$SOURCES_FILE"
}

require_command git
require_command rsync

mkdir -p "$SKILLS_ROOT"
install_sources
