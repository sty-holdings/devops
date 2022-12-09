#!/bin/bash
#
# This will edit the nats resolver config default location 
# for account jwts to $MY_NATS_HOME
#

NATS_RESOLVER_MOD_FILE=/tmp/nats_resolver_mod_file.tmp
MOD_NATS_RESOLVER=/tmp/mod_nats_resolver.sh

echo "==> Editing the resolver.conf file. Changing the dir from ./jwt to $MY_NATS_HOME/jwt"
cp $MY_NATS_HOME/includes/$MY_NATS_RESOLVER $MY_NATS_HOME/includes/OG_$MY_NATS_RESOLVER
echo $MY_NATS_HOME/jwt | sed {s/\\//\\\\\\\\\\//g} > $NATS_RESOLVER_MOD_FILE
#
echo -n "sed {s/'\.\/jwt/'" > $MOD_NATS_RESOLVER
cat $NATS_RESOLVER_MOD_FILE | tr -d '\n' >> $MOD_NATS_RESOLVER
echo "/} $MY_NATS_HOME/includes/OG_$MY_NATS_RESOLVER > $MY_NATS_HOME/includes/$MY_NATS_RESOLVER" >> $MOD_NATS_RESOLVER
chmod 755 $MOD_NATS_RESOLVER
sh $MOD_NATS_RESOLVER

echo "==> Setting $HOME/jwt group to nats group"
sudo chgrp nats $MY_NATS_HOME/jwt