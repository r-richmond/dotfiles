#!/bin/sh

# avoid --user https://docs.brew.sh/Homebrew-and-Python
uv tool install ruff
uv tool install pre-commit
uv tool install poetry --with keyrings-google-artifactregistry-auth --with poetry-plugin-export --with pip-system-certs
