# Dotfiles Setup

This script automates the process of setting up the sysetm from scratch to complete 10x dev.
It is designed to be run on Ubuntu-based sysetm and require root privileges.

## Features

- **System Update and Upgrade**:: Updates and upgrades system packages.
- **Package Installation**: Installs a predefined set of useful packages.
- **Neovim Installation**: Clones and builds Neovim from source.
- **WezTerm Installation**: Downloads and installs WezTerm terminal emulator.
- **Docker Installation**: Sets up Docker on the system.
- **Dotfiles Management**: Clones a repository of dotfiles, backs up existing configurations, and creates symlinks to the new dotfiles.

## How to Use!?

- Clone the repository:

```bash
git clone https://github.com/bad-Al-code/.dotfiles.git
cd .dotfiles/
```

- Run the script

> Make sure the script is executable

```bash
sudo chmod +x bash.sh
sudo ./bash.sh
```
