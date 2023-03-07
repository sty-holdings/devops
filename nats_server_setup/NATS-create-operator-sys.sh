#!/bin/bash
#
# This will create a user for SavUp App
#
NATS_OPERATOR=$1
NATS_HOME=$2
NATS_URL=$3
NKEYS_PATH=$4
SCRIPT_DIRECTORY=$5

. "${SCRIPT_DIRECTORY}"/execute-command.sh

echo " - Creating NSC operator: $NATS_OPERATOR"
CMD="nsc add operator --generate-signing-key --sys --name $NATS_OPERATOR"
executeCommand "$CMD"

echo "   - NSC operator will require signed keys for accounts on $NATS_URL"
CMD="nsc edit operator --require-signing-keys --account-jwt-server-url $NATS_URL"
executeCommand "$CMD"

echo "   - Creating SYS Account key file for SavUp to use for Dynamic Account/User creation."
if [ -f "$NATS_HOME"/.keys ]; then
  echo "   - $NATS_HOME/.keys already exists. No action taken."
else
  mkdir -p "$NATS_HOME"/.keys
fi
nsc list keys --all 2> /tmp/nats_keys.tmp
awk '$2=="SYS" && $6=="*" { print $4 } ' < /tmp/nats_keys.tmp > /tmp/SYS-signed.nk.tmp
b=$(cut -c2-3 < /tmp/SYS-signed.nk.tmp)
echo "$NKEYS_PATH"/keys/A/"$b"/*.nk > "$NATS_HOME"/SYS_SIGNED_KEY_LOCATION.nk
echo
