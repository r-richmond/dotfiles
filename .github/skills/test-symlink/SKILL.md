---
name: test-symlink
description: 'Validate all intended dotfiles symlink targets. Use when checking that every managed symlink exists and points to the expected source, especially after bootstrap, after adding a new symlink* file, or after moving dotfiles.'
argument-hint: 'No arguments required'
---

# Test Symlink

Use this skill to verify that every repo-managed `symlink*` file resolves to the expected target under `$HOME`.

## When to Use

- Validate the managed symlink set after `script/bootstrap`
- Check a new `symlink*` file before or after committing it
- Confirm the repo still owns the expected paths after moving or restoring dotfiles

## Procedure

1. Run the validation wrapper: [scripts/run.sh](./scripts/run.sh)
2. Review any failing statuses from `script/test-symlink`
3. If the output includes `MISSING` or `BROKEN`, follow up with [heal-symlink](../heal-symlink/SKILL.md) when repair is appropriate
4. If the output includes `MISMATCH`, inspect the destination manually before replacing it

## Status Meanings

- `OK`: the destination symlink points to the expected source
- `MISSING`: the destination path is not linked yet
- `BROKEN`: the destination is a symlink, but its target no longer exists
- `MISMATCH`: the destination points somewhere else
- `INVALID`: the source filename does not map to a valid path under `$HOME`

## Commands

- Wrapper script: [scripts/run.sh](./scripts/run.sh)
- Underlying repo script: `script/test-symlink`