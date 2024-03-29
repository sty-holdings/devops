#!/bin/bash
#
# This will create the nats-server resolver config
#
NATS_HOME=$1
NATS_WEBSOCKET_PORT=$2
NATS_CONF_NAME=$3
NATS_SERVER_NAME=$4
NATS_RESOLVER=$5
CERT_NAME=$6
KEY_NAME=$7
CA_NAME=$8

cat > "$NATS_HOME/$NATS_CONF_NAME" <<- EOF
	#listen: localhost:4222 # This will only allow access on the local host machine
	listen: 0.0.0.0:4222    # This will allow access from anywhere on the internet
	server_name: $NATS_SERVER_NAME

	include 'includes/$NATS_RESOLVER' # Pull in from file

EOF

if [ -n "$CERT_NAME" ]; then
	echo -e "tls: {\n		cert_file: \"${NATS_HOME}/.certs/${CERT_NAME}\"\n		key_file: \"${NATS_HOME}/.certs/${KEY_NAME}\"\n		ca_file: \"${NATS_HOME}/.certs/${CA_NAME}\"\n		verify: true\n		timeout: 2\n	}\n"
fi

if [ -n "$NATS_WEBSOCKET_PORT" ]; then
  echo -e "  websocket {\n    port: ${NATS_WEBSOCKET_PORT}\n    no_tls: true\n    compression: true\n  }" >> "$NATS_HOME/$NATS_CONF_NAME"
fi

msg="Created $NATS_HOME/$NATS_CONF_NAME file"
echo " - $msg"
echo "$msg" >> "$NATS_HOME"/NATS_log_file 2>> "$NATS_HOME"/NATS_log_file
echo >> "$NATS_HOME"/NATS_log_file 2>> "$NATS_HOME"/NATS_log_file
echo
