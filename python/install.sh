#!/usr/bin/env bash

set -e

if ! command -v uv >/dev/null 2>&1; then
	echo 'uv is required for python/install.sh'
	exit 1
fi

# avoid --user https://docs.brew.sh/Homebrew-and-Python
uv tool install --upgrade ruff
uv tool install --upgrade prek
