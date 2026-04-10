#!/usr/bin/env bash

set -e

# install java
if [ "$(uname -s)" != "Darwin" ]; then
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  echo 'brew not found, skipping java install.sh'
  exit 0
fi

jdk_link=/Library/Java/JavaVirtualMachines/openjdk.jdk
jdk_target="$(brew --prefix openjdk 2>/dev/null)/libexec/openjdk.jdk"

if [ ! -e "$jdk_link" ] && [ -d "$jdk_target" ]; then
  echo "setting java to use brew install openjdk"
  sudo ln -sfn "$jdk_target" "$jdk_link"
fi
