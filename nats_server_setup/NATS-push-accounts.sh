#!/bin/bash
#
# This will push all NSC accounts and user to NATS
NATS_HOME=$1
SCRIPT_DIRECTORY=$2

. "${SCRIPT_DIRECTORY}"/execute-command.sh

CMD='nsc push -A'
executeCommand "$CMD"

