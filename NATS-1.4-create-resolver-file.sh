#!/bin/bash
#
# This will create the nats-server resolver config
#

if [ -f "$NATS_HOME/includes/$NATS_RESOLVER" ]; then
	echo "==> Removing old $NATS_RESOLVER file"
	rm $NATS_HOME/includes/$NATS_RESOLVER
fi

echo "==> Setting operator and creating resolver config file"
#nsc env -o styh
CMD="nsc generate config --nats-resolver --sys-account SYS"
${CMD} >> $NATS_HOME/includes/$NATS_RESOLVER

