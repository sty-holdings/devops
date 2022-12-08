#!/bin/bash
#
# This will create an application user
#

echo "==> Create $MY_NATS_ACCOUNT $MY_NATS_USER user"
CMD="nsc add user --account $MY_NATS_ACCOUNT $MY_NATS_USER"
echo $CMD >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
${CMD} >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
echo >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
