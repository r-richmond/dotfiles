#!/bin/sh

# avoid --user https://docs.brew.sh/Homebrew-and-Python
pip3 install -q --upgrade pip
pip3 install -q --upgrade setuptools

pipx install black
pipx install flake8
pipx install isort
pipx install mypy
pipx inject mypy types-futures types-protobuf types-pytz types-PyYAML types-requests
pipx install poetry
pipx install pre-commit
pipx install ruff
