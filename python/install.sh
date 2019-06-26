#!/bin/sh

pip3 install -q --upgrade pip;
pip3 install -q --upgrade setuptools;
[ ! -d ~/python_virtual_envs ] && mkdir ~/python_virtual_envs;
pip3 install -q flake8;
pip3 install -q black;

[ ! -d ~/Dropbox ] && mkdir ~/Dropbox;
[ ! -d ~/Dropbox/python ] && mkdir ~/Dropbox/python;
