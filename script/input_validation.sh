#!/bin/bash

print_usage() {
  echo "Usage: $0 [options]"
  echo
  echo "Options:"
  echo "  --help                 Show this help message and exit."
  echo "  --skip-upgrade         Skip the system upgrade step."
  echo "  --user <username>      Specify the username for the installation."
  echo "  --dry-run              Enable dry-run mode (no changes will be made)."
  echo "  --verbose              Enable verbose logging."
  echo "  --log-file <path>      Specify a custom log file location."
  echo
  echo "Example:"
  echo "  $0 --skip-upgrade --user johndoe --dry-run --verbose"
}

log() {
  local message=$1
  if [ "$VERBOSE" = true ]; then
    echo "$DATE_TIME - $SCRIPT_NAME: $message" | tee -a "$LOG_FILE"
  else
    echo "$DATE_TIME - $SCRIPT_NAME: $message" >>"$LOG_FILE"
  fi
}

log_error() {
  local message=$1
  echo "$DATE_TIME - $SCRIPT_NAME [ERROR]: $message" | tee -a "$LOG_FILE" >&2
}

log_info() {
  local message=$1
  echo "$DATE_TIME - $SCRIPT_NAME [INFO]: $message" | tee -a "$LOG_FILE"
}

log_warning() {
  local message=$1
  echo "$DATE_TIME - $SCRIPT_NAME [WARNING]: $message" | tee -a "$LOG_FILE" >&2
}

perform_critical_operation() {
  local operation=$1
  if [ "$DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would perform: $operation"
  else
    eval "$operation"
    log_info "Performed: $operation"
  fi
}

parse_arguments() {
  SKIP_UPGRADE=false
  USERNAME="${USERNAME:-${DEFAULT_USERNAME}}"
  LOG_FILE="${LOG_FILE:-$HOME/dotfiles_update.log}"
  DRY_RUN=false
  VERBOSE=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --user)
      if [ -z "$2" ]; then
        log_error "The --user option requires a username."
        exit 1
      fi
      USERNAME="$2"
      log_info "Username set to: $USERNAME"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --log-file)
      if [ -z "$2" ]; then
        log_error "The --log-file option requires a file path."
        exit 1
      fi
      LOG_FILE="$2"
      shift 2
      ;;
    --skip-upgrade)
      SKIP_UPGRADE=true
      log_info "Skipping upgrade as requested."
      shift
      ;;
    --help)
      print_usage
      exit 0
      ;;
    *)
      log_error "Unknown argument: $1"
      print_usage
      exit 1
      ;;
    esac
  done
}

SCRIPT_NAME=$(basename "$0")
DATE_TIME=$(date +"%Y-%m-%d %H:%M:%S")

parse_arguments "$@"

export SKIP_UPGRADE
export USERNAME
export DRY_RUN
export VERBOSE
export LOG_FILE

if [[ $# -eq 0 ]]; then
  print_usage
  exit 0
fi

if [ "$DRY_RUN" = true ]; then
  log_info "Dry-run mode enabled. No changes will be made."
fi

log_info "Script execution completed."
