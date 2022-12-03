#!/bin/bash
#
# This will create the nats-server resolver config
#

NATS_HOME=/mnt/disks/nats_home
NATS_RESOLVER=resolver.conf

echo "--------------"
if [ -f "$NATS_HOME/includes/$NATS_RESOLVER" ]; then
	echo "==> Removing old $NATS_RESOLVER file"
	rm $NATS_HOME/includes/$NATS_RESOLVER
fi

echo "==> Setting operator and creating resolver config file"
nsc env -o styh
CMD="nsc generate config --nats-resolver --sys-account SYS"
${CMD} >> $NATS_HOME/includes/$NATS_RESOLVER

echo "--------------"
echo "==> Creating nats-server configuration file"
cat > "$NATS_HOME/nats.conf" <<- EOF

	listen: localhost:4222

	include 'includes/$NATS_RESOLVER' # Pull in from file

	#tls: {
	#	cert_file: "????"
	#	key_file: "????"
	#	verify: true
	#	timeout: 2
	#}

	#authorization: {
	#  token: login_auth_token
	#}

	websocket {
	  port: 8443
	  no_tls: true
	}


EOF

echo 
echo Done

