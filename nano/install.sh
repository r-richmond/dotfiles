#!/usr/bin/env bash

# git clone nano syntax highlighting
echo "Cloning fantastic nano syntax repo"
git clone https://github.com/scopatz/nanorc ~/.nano

# Manual Updates
git -C ~/.nano git pull
