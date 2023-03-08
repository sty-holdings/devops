#!/bin/bash
#
# This will create an application user
#
NATS_HOME=$1
SCRIPT_DIRECTORY=$2
NATS_USER_ACCOUNT=$3
NATS_USER=$4

. "${SCRIPT_DIRECTORY}"/execute-command.sh

CMD="nsc add user --account $NATS_USER_ACCOUNT $NATS_USER"
executeCommand "$CMD"
