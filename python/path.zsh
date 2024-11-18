# this adds .local/bin to the path; used by pipx
export PATH="/Users/$USER/.local/bin:$PATH"

# https://github.com/wbolster/plyvel/issues/100#issuecomment-1162625134
export LIBRARY_PATH="$LIBRARY_PATH:$(brew --prefix)/lib"
export CPATH="$CPATH:$(brew --prefix)/include"
