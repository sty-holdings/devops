#!/bin/bash
#
# This will create an application account and user
#

echo "==> Create $NATS_ACCOUNT account"
CMD="nsc add account $NATS_ACCOUNT"
echo $CMD >>NATS_log_file 2>>NATS_log_file
${CMD} >>NATS_log_file 2>>NATS_log_file

echo "==> Generate $NATS_ACCOUNT account signature key"
CMD="nsc edit account $NATS_ACCOUNT --sk generate"
echo $CMD >>NATS_log_file 2>>NATS_log_file
${CMD} >>NATS_log_file 2>>NATS_log_file

echo "==> Create $NATS_USER user"
CMD="nsc add user $NATS_USER"
echo $CMD >>NATS_log_file 2>>NATS_log_file
${CMD} >>NATS_log_file 2>>NATS_log_file
