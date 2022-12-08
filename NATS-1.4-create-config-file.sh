#!/bin/bash
#
# This will create the nats-server resolver config
#

echo "==> Creating nats-server configuration file"
cat > "$MY_NATS_HOME/nats.conf" <<- EOF

	listen: localhost:4222

	include 'includes/$MY_NATS_RESOLVER' # Pull in from file

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
	  port: 9222
	  no_tls: true
	  compression: true
	}


EOF

msg="Created $MY_NATS_HOME/nats.conf file"
echo $msg
echo $msg >>NATS_log_file 2>>NATS_log_file
echo >>NATS_log_file 2>>NATS_log_file