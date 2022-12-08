#!/bin/bash
#
# This will create an application account and user
#

echo "==> Create $MY_NATS_ACCOUNT account"
CMD="nsc add account $MY_NATS_ACCOUNT"
echo $CMD >>NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
${CMD} >>NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
echo >>NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file

echo "==> Generate $MY_NATS_ACCOUNT account signature key"
CMD="nsc edit account $MY_NATS_ACCOUNT --sk generate"
echo $CMD >>NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
${CMD} >>NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
echo >>NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file