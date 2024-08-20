#!/usr/bin/env bats

# Test case: No arguments provided should show usage information
@test "No arguments provided should show usage information" {
  run ./input_validation.sh
  [[ "$output" == *"Usage:"* ]]
}

# Test case: Unknown argument should result in an error
@test "Unknown argument should result in an error" {
  run ./input_validation.sh --unknown
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown argument"* ]]
}

# Test case: Help option should display usage information
@test "Help option should display usage information" {
  run ./input_validation.sh --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

# Test case: --user without a username should result in an error
@test "--user without a username should result in an error" {
  run ./input_validation.sh --user
  [ "$status" -ne 0 ]
  [[ "$output" == *"The --user option requires a username."* ]]
}

# Test case: --user with a valid username should succeed
@test "--user with a valid username should succeed" {
  run ./input_validation.sh --user testuser
  [ "$status" -eq 0 ]
  [[ "$output" == *"Username set to: testuser"* ]]
}

# Test case: --dry-run should enable dry-run mode
@test "--dry-run should enable dry-run mode" {
  run ./input_validation.sh --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"Dry-run mode enabled"* ]]
}

# Test case: --verbose should enable verbose logging
@test "--verbose should enable verbose logging" {
  run ./input_validation.sh --verbose
  [ "$status" -eq 0 ]
}

# Test case: --log-file sets a custom log file
@test "--log-file sets a custom log file" {
  run ./input_validation.sh --log-file /tmp/custom_log.log
  [ "$status" -eq 0 ]
}

# Test case: --skip-upgrade should be parsed successfully
@test "--skip-upgrade should be parsed successfully" {
  run ./input_validation.sh --skip-upgrade
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipping upgrade as requested."* ]]
}
