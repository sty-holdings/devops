#!/bin/bash
#
# This will create the nats-server resolver config
#
NATS_HOME=$1
NATS_RESOLVER=$2
SCRIPT_DIRECTORY=$3

. "${SCRIPT_DIRECTORY}"/execute-command.sh

echo "Creating NATS Resolver"
if [ -f "$NATS_HOME/includes/$NATS_RESOLVER" ]; then
	echo " - Removing old $NATS_RESOLVER file"
	rm "$NATS_HOME"/includes/"$NATS_RESOLVER"
fi

echo " - Setting NSC environment operator"
CMD="nsc env -o styh"
executeCommand "$CMD"

echo " - Creating resolver config file"
CMD="nsc generate config --nats-resolver --sys-account SYS --config-file $NATS_HOME/includes/$NATS_RESOLVER"
executeCommand "$CMD"
sudo chgrp nats "$NATS_HOME"/includes/"$NATS_RESOLVER"

echo "   - Setting $NATS_HOME/jwt group to nats"
sudo chgrp nats "$NATS_HOME"/jwt
echo
