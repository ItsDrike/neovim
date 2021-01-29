# Dotfiles

These are my personal dotfiles. This also include an automated installer for certain packages (Arch Linux specific) and for putting the dotfiles in place.
Source code for this automated script is in `src` directory, and the dotfiles are located in `home` and `root` directories respectively.

You are highly adviced to first go through these dotfiles yourself and adjust them to your liking.

## What does it do

- Fully fledged ZSH configuration without the need to rely on oh-my-zsh
  - oh-my-zsh configuration is also supported, but it is off by default, adjust [`.zshrc`](home/.zshrc) to enable it
  - Even though enabling it is an option, it is not a necessary thing to do, oh-my-zsh has a lot of code that is mostly irrelevant and unused, these dotfiles give you the ability to completely avoid it, if you desire to do so
- Custom [prompt](home/.config/sh/theme), both for oh-my-zsh configuration or for standalone usage
- Custom [VIM configuration](home/.config/vim/vimrc) (this was designed for regular vim, nvim support can't be guaranteed)
- Many handy [aliases](home/.config/sh/aliases) (likely too many, you should adjust that to your needs)
- [XDG configuration](home/.config/sh/environ) to avoid too much cluttering in home directory
- [Automatic handlers](home/.config/sh/handlers) which override default command not found behavior to show the package to which given command belongs (requires pkgfile on Arch Linux)
- Automated package installation for Arch Linux, which includes many handy packages. You should certainly take a look at which packages will be installed and adjust [`packages.yaml`](packages.yaml) before you run it.

## Requirements

Python 3 is requred to run the automated installation script, but you can move the files and optionally also install the packages from [`packages.yaml`](packages.yaml) manually.

## Sample images

- Prompt (Fully adjustable, either manually, or using other oh-my-zsh themes) ![image](https://user-images.githubusercontent.com/20902250/106213937-0df13180-61ce-11eb-9a06-867b89ea2fd6.png)
- Vim configuration (Fully adjustable, simply edit [`vimrc`](home/.config/vim/vimrc)) ![image](https://user-images.githubusercontent.com/20902250/106214028-3c6f0c80-61ce-11eb-96a2-3a46c77853e7.png)
- Automatic unknown command package handler ![image](https://user-images.githubusercontent.com/20902250/106214104-645e7000-61ce-11eb-9c80-d0762338ce59.png)


## Automated script usage

Clone this repository anywhere you like

`$ git clone https://github.com/ItsDrike/dotfiles`

Before you run, you should take a look at the files included and adjust them however you like.  
All files which will be added are in `home/` and `root/` directory.
You can remove files which you don't want, or adjust them in any way.  
You should also take a look at `packages.yaml` and remove all packages which you don't want and add those you do.

When you are prepared, you can run the installer

`$ python3 -m src` (assuming you're in the clonned repository)
