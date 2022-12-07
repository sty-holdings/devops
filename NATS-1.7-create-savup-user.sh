#!/bin/bash
#
# This will create an application user
#

echo "==> Create $MY_NATS_ACCOUNT $MY_NATS_USER user"
CMD="nsc add user --account $MY_NATS_ACCOUNT $MY_NATS_USER"
echo $CMD >>NATS_log_file 2>>NATS_log_file
${CMD} >>NATS_log_file 2>>NATS_log_file
echo >>NATS_log_file 2>>NATS_log_file
