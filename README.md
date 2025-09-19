# Dotfiles

My personal Linux dotfiles, made for Arch/Cinnamon.  
Mainly for my git, zsh and application configs. I am really happy with my [`.zshrc`](.zshrc) and my [`.gitconfig`](.gitconfig). This repo also includes [handy scripts](.local/bin) to add to your `$PATH`.

## Installation

Clone the repo into `~/.dotfiles`.

### Quick setup (symlinks everything)

```bash
chmod +x ~/.dotfiles/.local/bin/dotfiles
~/.dotfiles/.local/bin/dotfiles setup
```

This will create symlinks for all files that are in the `~/.dotfiles` into the appropriate place in `$HOME`.

### Manual installation

You can also create symlinks yourself by running the `dotfiles link` command.

```bash
~/.dotfiles/.local/bin/dotfiles link .zshrc
~/.dotfiles/.local/bin/dotfiles link .gitconfig
```

## Usage

**Once [`~/.local/bin/dotfiles`](.local/bin/dotfiles) and [`~/.zshrc`](.zshrc) has been symlinked, you can just use the `dotfiles` command.**

- `dotfiles setup` - symlink everything
- `dotfiles link <file>` - link a specific file
- `dotfiles add <file>` - add a new file to dotfiles
- `dotfiles git <args>` - run git commands in the dotfiles repo
