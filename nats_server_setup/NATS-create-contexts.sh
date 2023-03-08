#!/bin/bash
#
# This will create the nats context for SYS and the SavUp Account
NATS_HOME=$1
SCRIPT_DIRECTORY=$2
NATS_OPERATOR=$3
NATS_USER_ACCOUNT=$4
NATS_USER=$5

. "${SCRIPT_DIRECTORY}"/execute-command.sh

echo " - Creating the User context"
CMD="nats context save styh_savup --nsc nsc://$NATS_OPERATOR/$NATS_USER_ACCOUNT/$NATS_USER"
executeCommand "$CMD"
