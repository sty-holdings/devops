#!/bin/bash
#
# This will create the nats-server resolver config
#

if [ -f "$MY_NATS_HOME/includes/$MY_NATS_RESOLVER" ]; then
	echo "==> Removing old $MY_NATS_RESOLVER file"
	rm $MY_NATS_HOME/includes/$MY_NATS_RESOLVER
fi

echo "==> Setting NSC environment operator"
CMD="nsc env -o styh"
echo $CMD >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
${CMD} >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
echo >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file

echo "==> Creating resolver config file"
CMD="nsc generate config --nats-resolver --sys-account SYS --config-file $MY_NATS_HOME/includes/$MY_NATS_RESOLVER"
echo $CMD >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
${CMD}
echo >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file

echo "==> Setting $HOME/jwt group to nats group"
sudo chgrp nats $MY_NATS_HOME/jwt