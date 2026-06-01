---
description: "Use when editing dotfiles symlink behavior, path mapping, bootstrap link handling, symlink validation, symlink healing, or the Bash symlink test harness. Run the symlink regression tests before finishing."
name: "Symlink Regression Tests"
applyTo: "script/bootstrap, script/heal-symlink, script/test-symlink, script/lib/symlink, tests/script/**"
---

# Symlink Regression Tests

- When you change symlink behavior or path mapping, run `tests/script/run` before finishing.
- If you change the Bash test harness or runner, also run `bash -n tests/script/run tests/script/symlink_test.bash`.
- Run `shellcheck tests/script/run tests/script/symlink_test.bash` when ShellCheck is available.
- Keep test fixtures isolated under `tests/tmp` by overriding `DOTFILES` and `HOME`; do not test against the real home directory.
