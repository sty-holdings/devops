#!/bin/bash
#
# This will edit the nats resolver config default location 
# for account jwts. They will be moved to $NATS_HOME
#
NATS_HOME=$1
NATS_RESOLVER=$2
NATS_RESOLVER_MOD_FILE=/tmp/nats_resolver_mod_file.tmp
MOD_NATS_RESOLVER=/tmp/mod_nats_resolver.sh

echo " - Editing the resolver.conf file. Changing the dir from ./jwt to $NATS_HOME/jwt"
cp "$NATS_HOME"/includes/"$NATS_RESOLVER" "$NATS_HOME"/includes/OG_"$NATS_RESOLVER"
echo "$NATS_HOME"/jwt | sed {s/\\//\\\\\\\\\\//g} > $NATS_RESOLVER_MOD_FILE
#
echo -n "sed {s/'\.\/jwt/'" > $MOD_NATS_RESOLVER
tr -d '\n' >> $MOD_NATS_RESOLVER < "$NATS_RESOLVER_MOD_FILE"
echo "cp $NATS_HOME/includes/OG_$NATS_RESOLVER > $NATS_HOME/includes/$NATS_RESOLVER" >> $MOD_NATS_RESOLVER
chmod 755 $MOD_NATS_RESOLVER
sh $MOD_NATS_RESOLVER

echo "==> Setting $NATS_HOME/jwt group to nats group"
sudo chgrp nats "$NATS_HOME"/jwt
echo
