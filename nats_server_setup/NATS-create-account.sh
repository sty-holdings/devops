#!/bin/bash
#
# This will create an application account and user
#
NATS_USER_ACCOUNT=$1
SCRIPT_DIRECTORY=$2

. "${SCRIPT_DIRECTORY}"/execute-command.sh

echo " - Create $NATS_USER_ACCOUNT account"
CMD="nsc add account $NATS_USER_ACCOUNT"
executeCommand "$CMD"

echo "   - Generate $NATS_USER_ACCOUNT account signature key"
CMD="nsc edit account $NATS_USER_ACCOUNT --sk generate"
executeCommand "$CMD"
echo
