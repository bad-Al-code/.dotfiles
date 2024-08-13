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
