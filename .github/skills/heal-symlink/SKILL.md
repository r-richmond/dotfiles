---
name: heal-symlink
description: "Heal missing or broken dotfiles symlinks by running the repo repair flow. Use when test-symlink reports BROKEN or MISSING for managed targets that should be restored."
argument-hint: "No arguments required"
---

# Heal Symlink

Use this skill when a managed symlink under `$HOME` is missing or broken and should be restored to the repo-managed source.

## When to Use

- Repair a `BROKEN` result from `script/test-symlink`
- Recreate a `MISSING` managed symlink
- Recover after deleting a managed symlink or after moving the repo

## Procedure

1. Run the repair wrapper: [scripts/run.sh](./scripts/run.sh)
2. Let the script replace broken symlinks automatically
3. If a regular file exists where the symlink should go, answer the prompt:
   - `s`: skip it
   - `p`: print the current file contents
   - `r`: print the file, then replace it with the managed symlink
   - `m`: move the file into `backup-moved/`, then create the managed symlink
4. Confirm the final `Summary:` from `script/test-symlink` shows no remaining missing or broken targets

## Scope

- Repairs `MISSING` and `BROKEN` results from `script/test-symlink`
- Does not automatically resolve `MISMATCH` results; inspect those manually first

## Commands

- Wrapper script: [scripts/run.sh](./scripts/run.sh)
- Underlying repo script: `script/heal-symlink`
