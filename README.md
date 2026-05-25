# ~holman~ richmond does dotfiles

Your dotfiles are how you personalize your system. These are mine.

If you're interested in the philosophy behind why projects like these are
awesome, you might want to [read a post on the
subject](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/).

## topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory and put
files in there. Anything with an extension of `.zsh` will get automatically
included into your shell. Anything with a prefix of `symlink` will get
symlinked without the prefix into `$HOME` when you run `script/bootstrap`.
This differs from Holman's layout so the file extension stays unchanged, which
helps with syntax highlighting. A `+` in the filename maps to a `/` in the
destination path under `$HOME`.

## what's inside

A lot of stuff. Seriously, a lot of stuff. Check them out in the file browser
above and see what components may mesh up with you.
[Fork it](https://github.com/holman/dotfiles/fork), remove what you don't
use, and build on what you do use.

## components

There's a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is
  expected to setup `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded
  last and is expected to setup autocomplete.
- **topic/install.sh**: Any file named `install.sh` is executed when you run `script/install`. To avoid being loaded automatically, its extension is `.sh`, not `.zsh`.
- **topic/symlink\***: Any file starting with `symlink` gets symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory.
  - To further nest symlinks into subdirectories under `$HOME`, use `+` signs
    to signify additional directory delimiters. So for example, the file
    `topic/symlink.folder_name+file_name`
    would get symlinked to `$HOME/.folder_name/file_name` when you run `script/bootstrap`.

## symlink example

This repo uses the source filename to determine the destination path.

- `zsh/symlink.zshrc` becomes `~/.zshrc`
- `vscode/symlink.vscode+argv.json` becomes `~/.vscode/argv.json`

Run `script/bootstrap` to create the managed symlinks, and run
`script/test-symlink` to verify that they still point to the expected files.

## install

Run this:

```sh
git clone https://github.com/r-richmond/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

To validate that the expected symlinks are present and pointing at the right
files, run `script/test-symlink`. Subsequently, if you add new `symlink*`
files you can run `script/heal-symlink` to automatically restore missing or broken symlinks.

The main file you'll want to change right off the bat is `zsh/symlink.zshrc`,
which sets up a few paths that'll be different on your particular machine.

## bugs

I want this to work for everyone; that means when you clone it down it should
work for you even though you may not have `something` installed, for example. That
said, I do use this as _my_ dotfiles, so there's a good chance I may break
something if I forget to make a check for a dependency.

If you do hit an issue, feel free to [open an issue](https://github.com/r-richmond/dotfiles/issues)
and I'll do my best to fix it. If you want to contribute a fix, even better!

## thanks

I forked [Holman's](http://github.com/holman)' excellent
[dotfiles](http://github.com/holman/dotfiles) Most of the code in these dotfiles
stem or are inspired from Holman's original project.

## things left to do

- updated keyboard shortcuts
  - change caps to esc-key - system preferences > keyboard > modifier keys
  - add notification to option-` - system preferences > keyboard > shortcuts > mission control
  - change keyboard ctrl-option-cmd-space - system preferences > keyboard > shortcuts > input sources
- add mouse settings for buttons 4, 5, 3
  - system preferences > mission control >
- configure alfred powerpack
  - setup powerpack & link to sync folder & setup theme
- Figure out how to safe misc system preferences
  - keyboard shortcuts defined via macos

## FAQ

### 1. I want to get started quick. How do I install this on a new machine?

Clone the repo into `~/.dotfiles` and run the bootstrap script. That will set up the managed symlinks and kick off the installer flow for the topic directories.

```sh
git clone https://github.com/r-richmond/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

### 2. I added a new `.zsh` file. What do I need to do to have it take effect?

Files ending in `.zsh` are loaded by your shell startup flow, so after adding one you just need to start a new shell or reload your zsh config. If the file changes PATH setup or completion behavior, opening a fresh terminal is the safest option.

```sh
source ~/.zshrc
```

### 3. I added a new file that should be symlinked. How do I ensure it is named correctly and where it will go?

Name the file with a `symlink` prefix and treat `+` as a directory separator under `$HOME`. For example, `vscode/symlink.vscode+argv.json` maps to `~/.vscode/argv.json`, and `script/test-symlink` will verify that the destination is what you expect.

```sh
script/test-symlink
```

### 4. After I verify the file is set up properly and the symlink is in the right place, which script do I use to symlink it?

```sh
script/heal-symlink
```
