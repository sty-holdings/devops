#!/bin/bash
#
# This will create the nats-server resolver config
#
NATS_HOME=$1
NATS_WEBSOCKET_PORT=$2
NATS_CONF_NAME=$3
NATS_SERVER_NAME=$4
NATS_RESOLVER=$5

if [ -z "$NATS_WEBSOCKET_PORT" ]; then
  cat > "$NATS_HOME/$NATS_CONF_NAME" <<- EOF

	#listen: localhost:4222 # This will only allow access on the local host machine
	listen: 0.0.0.0:4222    # This will allow access from anywhere on the internet
	server_name: $NATS_SERVER_NAME

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

EOF
else
  cat > "$NATS_HOME/$NATS_CONF_NAME" <<- EOF

	#listen: localhost:4222 # This will only allow access on the local host machine
	listen: $NATS_URL # This will allow access from anywhere on the internet
	server_name: $NATS_SERVER_NAME

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
    port: ${NATS_WEBSOCKET_PORT}
    no_tls: true
    compression: true
  }
EOF
fi

msg="Created $NATS_HOME/$NATS_CONF_NAME file"
echo " - $msg"
echo "$msg" >> "$NATS_HOME"/NATS_log_file 2>> "$NATS_HOME"/NATS_log_file
echo >> "$NATS_HOME"/NATS_log_file 2>> "$NATS_HOME"/NATS_log_file
echo