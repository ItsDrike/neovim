# My personal neovim configuration

This repository includes my custom configuration of neovim.

## Sample image

![Screenshot_2021-12-06_14-31-37](https://user-images.githubusercontent.com/20902250/144854879-f35de259-cea1-4415-9a3b-b093fe008836.png)

## Usage

WIP: I've only recently migrated this repo from my dotfiles and I haven't yet gotten to documenting how to use my
neovim configuration in detail. I will add this soon-ish, thanks for understanding!


## Separation from my dotfiles

Previously, this was a part of my [dotfiles](https://github.com/ItsDrike/dotfiles), however I decided to separate it
into it's own repository, because it slowly grew to become the most updated part of my dotfiles and an isolated
repository simply made more sense, because there were some people who came to my dotfiles just to see my neovim
configuration. I also wanted to provide a full and nicer readme in which I could document how to work with my
configuration and what exactly it supports. This was too inconvenient to do in my dotfiles alone, because it's readme
is also documenting everything else about my system configuration and it would be way too big to include neovim config
there. However, to keep things consistent there is still a git submodule in the dotfiles repository linking back to
this repo.

Note: I've manually copied the git history affecting `home/.config/nvim` from my dotfiles repository to this one so
that there is still a stable record of what was done to my neovim configuration and when. This however doesn't include
my old vim configuration because it was in `home/.vimrc` instead, so if you are interested in that, you can still check
the original commit history in my dotfiles repository.
