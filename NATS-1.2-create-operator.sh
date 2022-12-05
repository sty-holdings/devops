#!/bin/bash
#
# This will create a user for SavUp App
#

echo "==> Creating NSC operator"
CMD="nsc add operator --generate-signing-key --sys --name $NATS_OPERATOR"
${CMD}
echo "==> NSC operator will require keys and push them to $NATS_URL"
CMD="nsc edit operator --require-signing-keys --account-jwt-server-url $NATS_URL"
${CMD}
