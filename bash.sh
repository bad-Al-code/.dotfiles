#!/bin/bash

set -euo pipefail

SCRIPT_NAME=$(basename "$0")
LOG_FILE="$HOME/dotfiles_update.log"
DATE_TIME=$(date +"%Y-%m-%d %H:%M:%S")
APT_OPTIONS="-y"

log() {
  echo "$DATE_TIME - $SCRIPT_NAME: $1" | tee -a "$LOG_FILE"
}

if [[ $EUID -ne 0 ]]; then
  log "This script must be run as root. Exiting."
  exit 1
fi

update_system() {
  log "Starting system update and upgrade..."

  if apt update $APT_OPTIONS; then
    log "Package list updated successfully."
  else
    log "Failed to update package list."
    exit 1
  fi

  if apt upgrade $APT_OPTIONS; then
    log "System upgraded successfully."
  else
    log "Failed to upgrade system packages."
    exit 1
  fi

  log "System update and upgrade completed."
}

update_system

PACKAGES=(
  vim
  curl
  wget
  p7zip-full
  ffmpeg
  tmux
  build-essential
  i3
  i3status
  software-properties-common
  nitrogen
  btop
  obs-studio
  tree
  usb-creator-gtk
  cmake
  gpg
  xclip
  picom
  htop
  git
)

install_packages() {
  log "Starting package installation..."

  if apt update $APT_OPTIONS; then
    log "Package list updated successfully."
  else
    log "Failed to update package list."
    exit 1
  fi

  for package in "${PACKAGES[@]}"; do
    if apt install $APT_OPTIONS "$package"; then
      log "Package '$package' installed successfully."
    else
      log "Failed to install package '$package'."
      exit 1
    fi
  done

  log "All packages installed successfully."
}

install_packages

# Neovim
NEOVIM_DIR="$HOME/neovim"
NEOVIM_REPO="https://github.com/neovim/neovim.git"

DEPENDENCIES=(
  ninja-build
  gettext
  libtool
  libtool-bin
  autoconf
  automake
  cmake
  g++
  pkg-config
  unzip
  curl
  doxygen
)

install_dependencies() {
  log "Installing dependencies for building Neovim..."

  if apt update $APT_OPTIONS; then
    log "Package list updated successfully."
  else
    log "Failed to update package list."
    exit 1
  fi

  for dependency in "${DEPENDENCIES[@]}"; do
    if apt install $APT_OPTIONS "$dependency"; then
      log "Dependency '$dependency' installed successfully."
    else
      log "Failed to install dependency '$dependency'."
      exit 1
    fi
  done

  log "All dependencies installed successfully."
}

clone_neovim_repo() {
  log "Cloning Neovim repository..."

  if [[ -d "$NEOVIM_DIR" ]]; then
    log "Neovim directory already exists. Skipping clone."
    return
  fi

  if git clone "$NEOVIM_REPO" "$NEOVIM_DIR"; then
    log "Neovim repository cloned successfully."
  else
    log "Failed to clone Neovim repository."
    exit 1
  fi
}

build_and_install_neovim() {
  log "Building Neovim from source..."

  cd "$NEOVIM_DIR" || exit

  if make CMAKE_BUILD_TYPE=Release; then
    log "Neovim built successfully."
  else
    log "Failed to build Neovim."
    exit 1
  fi

  if make install; then
    log "Neovim installed successfully."
  else
    log "Failed to install Neovim."
    exit 1
  fi
}

# Check if Neovim is already installed
if [[ -n "$NVIM_BIN" ]]; then
  log "Neovim is already installed at '$NVIM_BIN'. Skipping build."
else
  install_dependencies
  clone_neovim_repo
  build_and_install_neovim
fi

log "Neovim installation process completed."

# Wezterm
WEZTERM_REPO="https://github.com/wez/wezterm/releases/latest/download/wezterm.deb"
WEZTERM_DEB="$HOME/wezterm.deb"

install_dependencies() {
  log "Installing dependencies for WezTerm..."

  if apt update $APT_OPTIONS; then
    log "Package list updated successfully."
  else
    log "Failed to update package list."
    exit 1
  fi

  if apt install $APT_OPTIONS wget gdebi-core; then
    log "Dependencies installed successfully."
  else
    log "Failed to install dependencies."
    exit 1
  fi
}

download_wezterm() {
  log "Downloading WezTerm..."

  if wget -O "$WEZTERM_DEB" "$WEZTERM_REPO"; then
    log "WezTerm downloaded successfully."
  else
    log "Failed to download WezTerm."
    exit 1
  fi
}

install_wezterm() {
  log "Installing WezTerm..."

  if gdebi $APT_OPTIONS "$WEZTERM_DEB"; then
    log "WezTerm installed successfully."
  else
    log "Failed to install WezTerm."
    exit 1
  fi

  # Clean up the .deb file
  rm "$WEZTERM_DEB"
  log "Cleaned up temporary files."
}

install_dependencies
download_wezterm
install_wezterm

log "WezTerm has been installed successfully."

# Docker
if [[ $EUID -ne 0 ]]; then
  log "This script must be run as root. Exiting."
  exit 1
fi

install_docker() {
  log "Installing Docker dependencies..."

  if apt update $APT_OPTIONS; then
    log "Package list updated successfully."
  else
    log "Failed to update package list."
    exit 1
  fi

  if apt install $APT_OPTIONS \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common; then
    log "Dependencies installed successfully."
  else
    log "Failed to install dependencies."
    exit 1
  fi

  if curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg; then
    log "Docker GPG key added successfully."
  else
    log "Failed to add Docker GPG key."
    exit 1
  fi

  if echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null; then
    log "Docker repository added successfully."
  else
    log "Failed to add Docker repository."
    exit 1
  fi

  if apt update $APT_OPTIONS; then
    log "Package list updated with Docker repository."
  else
    log "Failed to update package list after adding Docker repository."
    exit 1
  fi

  if apt install $APT_OPTIONS docker-ce docker-ce-cli containerd.io; then
    log "Docker installed successfully."
  else
    log "Failed to install Docker."
    exit 1
  fi

  # Enable Docker to start on boot
  if systemctl enable docker; then
    log "Docker service enabled to start on boot."
  else
    log "Failed to enable Docker service."
    exit 1
  fi

  # Start Docker service
  if systemctl start docker; then
    log "Docker service started successfully."
  else
    log "Failed to start Docker service."
    exit 1
  fi

  log "Docker installation completed."
}

install_docker

# Clone dotfiles
GITHUB_REPO="https://github.com/HeyBadAl/dotfiles"
CLONE_DIR="$HOME/dotfiles"

if [[ $EUID -ne 0 ]]; then
  log "This script must be run as root or with sudo privileges. Exiting."
  exit 1
fi

# check if git is installed
check_git() {
  if command -v git &>/dev/null; then
    log "Git is already installed."
  else
    log "Git is not installed. Installing Git..."
    apt update -y && apt install -y git
    log "Git installed successfully."
  fi
}

clone_repo() {
  if [[ -d "$CLONE_DIR" ]]; then
    log "Directory '$CLONE_DIR' already exists. Skipping clone."
  else
    log "Cloning repository from '$GITHUB_REPO' to '$CLONE_DIR'..."
    git clone "$GITHUB_REPO" "$CLONE_DIR"
    log "Repository cloned successfully."
  fi
}

check_git
clone_repo

log "Repository setup completed."
