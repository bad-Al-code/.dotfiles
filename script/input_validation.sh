#!/bin/bash

print_usage() {
  echo "Usage: $0 [options]"
  echo
  echo "Options:"
  echo "  --help                 Show this help message and exit."
  echo "  --skip-upgrade         Skip the system upgrade step."
  echo "  --user <username>      Specify the username for the installation."
  echo
  echo "Example:"
  echo "  $0 --skip-upgrade --user johndoe"
}

parse_arguments() {
  SKIP_UPGRADE=false
  USERNAME=""

  while [[ $# -gt 0 ]]; do
    case $1 in
    --help)
      print_usage
      exit 0
      ;;
    --skip-upgrade)
      SKIP_UPGRADE=true
      shift
      ;;
    --user)
      if [[ -n $2 ]]; then
        USERNAME=$2
        shift 2
      else
        echo "Error: --user requires a username."
        print_usage
        exit 1
      fi
      ;;
    *)
      echo "Error: Unknown option '$1'"
      print_usage
      exit 1
      ;;
    esac
  done

  # If USERNAME is not set, print an error and usage instructions
  if [[ -z $USERNAME ]]; then
    echo "Error: --user is required."
    print_usage
    exit 1
  fi
}

# Export the parsed variables
export SKIP_UPGRADE
export USERNAME
