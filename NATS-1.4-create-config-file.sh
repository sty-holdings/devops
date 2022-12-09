#!/bin/bash
#
# This will create the nats-server resolver config
#

echo "==> Creating nats-server configuration file"
cat > "$MY_NATS_HOME/nats.conf" <<- EOF

	#listen: localhost:4222 # This will only allow access on the local host machine
	listen: $MY_NATS_URL # This will allow access from anywhere on the internet
	server_name: $MY_NATS_SERVER_NAME

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
echo $msg >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
echo >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
