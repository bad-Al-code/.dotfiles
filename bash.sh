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
NVIM_BIN=$(command -v nvim || echo "")
if [[ -n "$NVIM_BIN" ]]; then
  log "Neovim is already installed at '$NVIM_BIN'. Skipping build."
else
  install_dependencies
  clone_neovim_repo
  build_and_install_neovim
fi

log "Neovim installation process completed."

# wezterm
install_dependencies() {
  log "Installing dependencies for WezTerm..."

  if apt update $APT_OPTIONS; then
    log "Package list updated successfully."
  else
    log "Failed to update package list."
    exit 1
  fi

  if apt install $APT_OPTIONS curl gpg apt-transport-https; then
    log "Dependencies installed successfully."
  else
    log "Failed to install dependencies."
    exit 1
  fi
}

add_wezterm_repo() {
  log "Adding WezTerm APT repository..."

  if curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg; then
    log "WezTerm GPG key added successfully."
  else
    log "Failed to add WezTerm GPG key."
    exit 1
  fi

  if echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list; then
    log "WezTerm repository added successfully."
  else
    log "Failed to add WezTerm repository."
    exit 1
  fi
}

install_wezterm() {
  log "Installing WezTerm..."

  if apt update $APT_OPTIONS; then
    log "Package list updated successfully after adding WezTerm repository."
  else
    log "Failed to update package list after adding WezTerm repository."
    exit 1
  fi

  if apt install $APT_OPTIONS wezterm; then
    log "WezTerm installed successfully."
  else
    log "Failed to install WezTerm."
    exit 1
  fi
}

install_dependencies
add_wezterm_repo
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

# handle if dotfiles is already exits
handle_existing_dotfiles() {
  if [[ -d "$CLONE_DIR" ]]; then
    log "Directory '$CLONE_DIR' already exists."
    log "Backing up existing directory to '$BACKUP_DIR'..."
    mv "$CLONE_DIR" "$BACKUP_DIR"
    log "Backup completed successfully."
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
handle_existing_dotfiles
clone_repo

log "Repository setup completed."

# symlink
DOTFILES_DIR="$HOME/dotfiles"
TARGET_DIR="$HOME/.config"

DIRECTORIES=(
  "bash"
  "bat"
  "btop"
  "git"
  "i3"
  "i3status"
  "k9s"
  "lazygit"
  "neofetch"
  "nitrogen"
  "nvim"
  "p10k"
  "picom"
  "rofi"
  "starship"
  "tmux"
  "ulauncher"
)

create_symlink() {
  local src=$1
  local dest=$2

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -d "$dest" ]; then
      echo "Removing existing directory: $dest"
      rm -rf "$dest"
    elif [ -f "$dest" ]; then
      echo "Removing existing file: $dest"
      rm "$dest"
    fi
  fi

  ln -s "$src" "$dest"
  echo "Created symlink: $dest -> $src"
}

for dir in "${DIRECTORIES[@]}"; do
  src="$DOTFILES_DIR/.config/$dir"
  dest="$TARGET_DIR/$dir"

  # Check if source directory exists
  if [ -d "$src" ]; then
    # Ensure target directory exists or create it
    if [ ! -d "$TARGET_DIR" ]; then
      echo "Creating target directory: $TARGET_DIR"
      mkdir -p "$TARGET_DIR"
    fi
    create_symlink "$src" "$dest"
  else
    echo "Warning: $src does not exist."
  fi
done

INDIVIDUAL_FILES=(
  "$DOTFILES_DIR/.bashrc"
  "$DOTFILES_DIR/.vimrc"
  "$DOTFILES_DIR/.tmux.conf"
)

for file in "${INDIVIDUAL_FILES[@]}"; do
  dest="$HOME/$(basename $file)"

  # Check if source file exists
  if [ -f "$file" ]; then
    create_symlink "$file" "$dest"
  else
    echo "Warning: $file does not exist."
  fi
done

echo "Symlink setup completed."
