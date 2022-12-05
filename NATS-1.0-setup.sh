#!/bin/bash
#
# Setting needed variables for NATS install and config scripts
#

echo
echo "================================"
echo "  N    N    AA    TTTTTT   SSSS"
echo "  NN   N   A  A     TT    S    "
echo "  N N  N   AAAA     TT     SSS "
echo "  N  N N   A  A     TT        S"
echo "  N   NN  A    A    TT    SSSS "
echo "==============================="
echo

echo "--------------------------"
echo " Setting script variables "
export NATS_HOME=/mnt/disks/nats_home
#
export NATS_BIN=/usr/bin/nats-server
export NATS_CLI_BIN=/usr/bin/nats
export NSC_BIN=/usr/bin/nsc
export NATS_HOME=/mnt/disks/nats_home
export NATS_RESOLVER=resolver.conf
#
export NATS_OPERATOR=styh
export NATS_ACCOUNT=SAVUP
export NATS_USER=savup
#
export NATS_URL=nats://0.0.0.0:4222
#
export SHOW_MOUNT_NOTES=0
#

echo
echo "==========="
echo "==> Creating the $HOME/.bash_exports"
echo
if grep -q $$NATS_URL "$HOME/.bash_exports"; then
	echo "==> NATS exports already exist"
else
	cat >> "$HOME/.bash_exports" <<- EOF
		export NATS_URL=$NATS_URL
		export NATS_HOME=$NATS_HOME
	EOF
fi


echo
echo "==========="
echo "NEXT: Install NATS server, NATS CLI, and NSC"
echo
echo " Do you want to continue (y/N)"
read continue
if [ "$continue" == "y" ]; then
	sh $HOME/NATS-1.1-install-nats-natscli-nsc.sh
else 
	exit
fi

echo
echo "==========="
echo "NEXT: Creating NATS operator and SYS account"
echo
echo " Do you want to continue (y/N)"
read continue
if [ "$continue" == "y" ]; then
	sh $HOME/NATS-1.2-create-operator.sh
else 
	exit
fi

echo
echo "==========="
echo "NEXT: Creating NATS SAVUP account and savup user"
echo
echo " Do you want to continue (y/N)"
read continue
if [ "$continue" == "y" ]; then
	sh $HOME/NATS-1.2.1-create-savup-account-user.sh
else 
	exit
fi

echo
echo "==========="
echo "NEXT: Creating NATS config file"
echo
echo " Do you want to continue (y/N)"
read continue
if [ "$continue" == "y" ]; then
	sh $HOME/NATS-1.3-create-config-file.sh
else 
	exit
fi

echo
echo "==========="
echo "NEXT: Creating NATS resolver file"
echo
echo " Do you want to continue (y/N)"
read continue
if [ "$continue" == "y" ]; then
	sh $HOME/NATS-1.4-create-resolver-file.sh
else 
	exit
fi

echo "==========="
echo
echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo
echo "==> You are about to start the NATS server in background mode"
echo "==>"
echo "==>"
echo " Do you want to continue (y/N)"
read continue
if [ "$continue" == "y" ]; then
	nohup sh $HOME/NATS-1.5-start-server.sh & </dev/null &>/dev/null
else 
	exit
fi

echo
echo "==========="
echo "NEXT: Pushing NSC account to Nats server"
echo
echo " Do you want to continue (y/N)"
read continue
if [ "$continue" == "y" ]; then
	sh $HOME/NATS-1.6-push-accounts-users.sh
else 
	exit
fi

echo
echo "==========="
echo "NEXT: Creating NATS contexts"
echo
echo " Do you want to continue (y/N)"
read continue
if [ "$continue" == "y" ]; then
	sh $HOME/NATS-1.7-create-contexts.sh
else 
	exit
fi

echo
echo "==========="
echo "NEXT: Clean up and next steps "
echo
echo " Do you want to continue (y/N)"
read continue
if [ "$continue" == "y" ]; then
	if [ "$SHOW_MOUNT_NOTES" == "1" ]; then
		sh $HOME/NATS-1.9-cleanup.sh
		echo
		echo "==> Clean up is done"
	fi
fi
