#!/bin/bash
#
# Name: NATS-1.0-setup.sh
#
# Description: Installs a stand alone instance of the NATS server
#
# Installation:
#   None required
#
# Copyright (c) 2022 STY-Holdings Inc
# All Rights Reserved
#

set -eo pipefail

# script variables
# shellcheck disable=SC2006
FILENAME=$(basename "$0")
# Directory and files
ROOT_DIRECTORY=/home/scott_yacko_sty_holdings_com
SCRIPT_DIRECTORY=${ROOT_DIRECTORY}/scripts
NATS_OPERATOR=""
NATS_ACCOUNT=""
NATS_USER=""
NATS_URL=""
NATS_SERVER_NAME=""
NATS_WEBSOCKET_PORT=""
# Internal Variables
MY_NATS_BIN=/usr/bin/nats-server
MY_NATS_CLI_BIN=/usr/bin/nats
MY_NSC_BIN=/usr/bin/nsc
MY_NATS_HOME=/mnt/disks/nats_home
MY_NATS_RESOLVER=resolver.conf
MY_NATS_CONF=nats.conf
MY_NATS_PID=nats.pid
MY_NATS_PID_RUNNING=nats.pid.running

function init_script() {
  . "${SCRIPT_DIRECTORY}"/echo-colors.sh
}

function display_savup() {
  echo "  ======================================"
  echo "     SSSS    AA    V    V  U   U  PPPP  "
  echo "    S       A  A   V    V  U   U  P   P "
  echo "     SSS    AAAA    V  V   U   U  PPPP  "
  echo "        S  A    A   V  V   U   U  P     "
  echo "    SSSS   A    A    VV     UUU   P     "
  echo "  ======================================"
  echo
  echo " NATS SERVER installation and configuration"
}

function displayAlert() {
	echo
	echo "**********************************"
	echo 
	echo "  AA   L      EEEEEE RRRR   TTTTT"
	echo " A  A  L      E      R   R    T  "
	echo " AAAA  L      EEEE   RRRR     T  "
	echo "A    A L      E      R   R    T  "
	echo "A    A LLLLLL EEEEEE R    R   T  "
	echo 
	echo "**********************************"
	echo
}

function displayStepSpacer() {
	echo "--------------------------"
}

function isNATSAlreadyRunning() {
  sudo ps aux | grep nats-server | awk '/nats.conf/' > /tmp/natsAUX.tmp
  NATS_PID=$(sudo cat /tmp/natsAUX.tmp | awk '//{print $2}')

  if [ -z "$NATS_PID" ]; then
   	displayAlert
    	echo " A NATS Server is already running on this system."
    	echo
    	echo " Please investigate the configuration of this system."
    	echo
    	echo "NATS PID: $NATS_PID"
    	echo
    	echo "You must stop NATS before this script will run."
    	echo
    	echo "run: kill -USR2 $NATS_PID"
    	echo
    	exit 1
  fi
}

function set_variable() {
  cmd="${1}=$2"
  eval "$cmd"
  cmd="${1}_CHECKED=\"true\""
  eval "$cmd"
}

function validate_parameters() {
  if [ -z "$GC_INSTANCE_ADDRESS_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The address parameter is missing"
  fi
  if [ -z "$GC_INSTANCE_NUMBER_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The number parameter is missing"
  fi
  if [ -z "$GC_FIREWALL_TAGS_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The firewall tags parameter is missing"
  fi

  if [ "$Failed" == "true" ]; then
    print_usage
    exit 1
  fi
}

function print_usage() {
  echo
  echo "This will create an instance on GCloud."
  echo
  echo "Usage: ${FILENAME} -h | -o {operator name} -a {account name} -u {user name} -n {url} -s {server name} -w {port number}"
  echo
  echo "flags:"
  echo -e "  -h\t\t display help"
  echo -e "  -o {operator name} The name of the operator."
  echo -e "  -a {account name}  The name of the starter account."
  echo -e "  -u {user name} The name of the starter user."
  echo -e "  -n {url} The URL for the server. This has to be set up in DNS or the host file."
  echo -e "  -s {server name} The instance name of the server."
  echo -e "  -w {port number} Optional - Websocket port number. Recommend 9222"
  echo
}

# Main function of this script
function run_script {
  if [ "$#" == "0" ]; then
    print_error "ERROR: No parameters where provided."
    print_usage
    exit 1
  fi

  display_savup
  isNATSAlreadyRunning

  while getopts 'o:a:u:n:s:w:h' OPT; do # see print_usage
    case "$OPT" in
    o)
      set_variable NATS_OPERATOR "$OPTARG"
      ;;
    a)
      set_variable NATS_ACCOUNT "$OPTARG"
      ;;
    u)
      set_variable NATS_USER "$OPTARG"
      ;;
    n)
      set_variable NATS_URL "$OPTARG"
      ;;
    s)
      set_variable NATS_SERVER_NAME "$OPTARG"
      ;;
    w)
      set_variable NATS_WEBSOCKET_PORT "$OPTARG"
      ;;
    h)
      print_usage
      exit 0
      ;;
    *)
      print_error "${RED}ERROR: Please review the usage printed below:${COLOR_OFF}" >&2
      print_usage
      exit 1
      ;;
    esac
  done

#displayStepSpacer()
#echo " WARNING"
#echo " WARNING: You are about to remove the existing NATS server and all files!! "
#echo " WARNING"
#echo
#echo " Do you want to SKIP this step? (Y/n)"
#echo "                ----"
#read continue
#if [ "$continue" == "n" ]; then
#	sudo rm -rf $MY_NATS_HOME/*
#	sudo rm $MY_NATS_BIN
#	sudo rm $MY_NATS_CLI_BIN
#	sudo rm $MY_NSC_BIN
#	rm -rf $HOME/.config/NATS
#	rm -rf $HOME/.local/NATS
#	rm -rf $HOME/.local/share
#	rm -rf $HOME/NATS
#	rm -rf $HOME/jwt
#	rm $MY_NATS_HOME/NATS_log_file
#	echo
#	echo " Do you want RESTART the system? (y/N)"
#	echo "             -------"
#		read restart
#	if [ "$restart" == "y" ]; then
#		sudo shutdown -r now
#		exit
#	fi
#fi
#
#echo
#echo "==========="
#echo "==> Appending NATS to the $HOME/.bash_exports"
#echo
#if grep -q $MY_NATS_URL "$HOME/.bash_exports"; then
#	echo "==> NATS exports already exist"
#else
#	cat >> "$HOME/.bash_exports" <<- EOF
#		export NATS_URL=$MY_NATS_URL
#		export NATS_HOME=$MY_NATS_HOME
#	EOF
#fi
#
#
#
#displayStepSpacer()
#echo "NEXT: Install NATS server, NATS CLI, and NSC"
#echo
#echo " Do you want to SKIP this step? (Y/n)"
#echo "                ----"
#read continue
#if [ "$continue" == "n" ]; then
#	sh $HOME/NATS-1.1-install-nats-natscli-nsc.sh
#fi
#
#displayStepSpacer()
#echo "NEXT: Creating NATS operator and SYS"
#echo
#echo " Do you want to SKIP this step? (Y/n)"
#echo "                ----"
#read continue
#if [ "$continue" == "n" ]; then
#	sh $HOME/NATS-1.2-create-operator-sys.sh
#fi
#
#displayStepSpacer()
#echo "NEXT: Creating NATS SAVUP account"
#echo
#echo " Do you want to SKIP this step? (Y/n)"
#echo "                ----"
#read continue
#if [ "$continue" == "n" ]; then
#	sh $HOME/NATS-1.2.1-create-savup-account.sh
#fi
#
#displayStepSpacer()
#echo "NEXT: Creating NATS resolver file"
#echo
#echo " Do you want to SKIP this step? (Y/n)"
#echo "                ----"
#read continue
#if [ "$continue" == "n" ]; then
#	sh $HOME/NATS-1.3-create-resolver-file.sh
#	sh $HOME/NATS-1.3.1-edit-jwt-dir.sh
#fi
#
#displayStepSpacer()
#echo "NEXT: Creating NATS config file"
#echo
#echo " Do you want to SKIP this step? (Y/n)"
#echo "                ----"
#read continue
#if [ "$continue" == "n" ]; then
#	sh $HOME/NATS-1.4-create-config-file.sh
#fi
#
#displayStepSpacer()
#echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
#echo "==> XX WARNING - VERY IMPORTANT     XX"
#echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
#echo
#echo "==> You are about to start the NATS server in background mode"
#echo "==>"
#echo "==>"
#echo " Do you want to SKIP this step? (Y/n)"
#echo "                ----"
#read continue
#if [ "$continue" == "n" ]; then
#	sh $HOME/NATS-1.5-start-server.sh &
#	sleep 2
#	sudo ps aux | grep nats-server | awk '/nats.conf/' > /tmp/natsAUX.tmp
#	NATS_PID=$(sudo cat /tmp/natsAUX.tmp | awk '//{print $2}')
#	if [[ -z "$NATS_PID" ]]; then
#		echo "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
#		echo "ZZ      SERVER DID NOT START        ZZ"
#		echo "ZZ           EXISTING               ZZ"
#		echo "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
#		exit
#	fi
#fi
#
#displayStepSpacer()
#echo "NEXT: Pushing NSC account to NATS server"
#echo
#echo " Do you want to SKIP this step? (Y/n)"
#echo "                ----"
#read continue
#if [ "$continue" == "n" ]; then
#	sh $HOME/NATS-1.6-push-accounts.sh
#fi
#
#displayStepSpacer()
#echo "NEXT: Creating NATS savup user"
#echo
#echo " Do you want to SKIP this step? (Y/n)"
#echo "                ----"
#read continue
#if [ "$continue" == "n" ]; then
#	sh $HOME/NATS-1.7-create-savup-user.sh
#fi
#
#displayStepSpacer()
#echo "NEXT: Creating NATS contexts"
#echo
#echo " Do you want to SKIP this step? (Y/n)"
#echo "                ----"
#read continue
#if [ "$continue" == "n" ]; then
#	sh $HOME/NATS-1.7.1-create-contexts.sh
#fi
#
#displayStepSpacer()
#echo "NEXT: Clean up and next steps "
#echo
#echo " Do you want to SKIP this step? (Y/n)"
#echo "                ----"
#read continue
#if [ "$continue" == "n" ]; then
#	sh $HOME/NATS-1.9-cleanup.sh
#	echo
#	echo "==> Clean up is done"
#fi
}

init_script
run_script "$@"
