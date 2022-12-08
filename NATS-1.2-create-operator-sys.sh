#!/bin/bash
#
# This will create a user for SavUp App
#

echo "==> Creating NSC operator"
CMD="nsc add operator --generate-signing-key --sys --name $MY_NATS_OPERATOR"
echo $CMD >>NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
${CMD} >>NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
echo >>NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file

echo "==> NSC operator will require keys and push them to $MY_NATS_URL"
CMD="nsc edit operator --require-signing-keys --account-jwt-server-url $MY_NATS_URL"
echo $CMD >>NATS_log_file 2>>N$MY_NATS_HOME/ATS_log_file
${CMD} >>NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
echo >>NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file