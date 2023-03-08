#!/bin/bash
#
# This will create the nats context for SYS and the SavUp Account
NATS_HOME=$1
SCRIPT_DIRECTORY=$2
NATS_OPERATOR=$3

. "${SCRIPT_DIRECTORY}"/execute-command.sh

CMD="nats context save ${NATS_OPERATOR}_sys --nsc nsc://$NATS_OPERATOR/SYS/sys"
executeCommand "$CMD"
