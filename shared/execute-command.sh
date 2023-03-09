#!/bin/bash
#
# This is reusable code for logging and execute NATS NSC commands
#

# shellcheck disable=SC2129
function executeCommand() {
  echo "PASSED A"
  echo "$1" >>"$NATS_HOME"/NATS_log_file 2>> "$NATS_HOME"/NATS_log_file
  ${1} >> "$NATS_HOME"/NATS_log_file 2>> "$NATS_HOME"/NATS_log_file
  echo >> "$NATS_HOME"/NATS_log_file 2>> "$NATS_HOME"/NATS_log_file
  echo "PASSED b"
}


