#!/bin/bash
#
# This will create an application account and user
#

echo "==> Create $NATS_ACCOUNT account"
CMD="nsc add account $NATS_ACCOUNT"
${CMD}
echo "==> Generate $NATS_ACCOUNT account signature key"
CMD="nsc edit account $NATS_ACCOUNT --sk generate"
${CMD}
echo "==> Create $NATS_USER user"
CMD="nsc add user $NATS_USER"
${CMD}
