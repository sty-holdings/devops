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
# shellcheck disable=SC2028
set -eo pipefail

# script variables
# shellcheck disable=SC2006
FILENAME=$(basename "$0")
# Directory and files
ROOT_DIRECTORY=/home/scott_yacko_sty_holdings_com # Remote instance
SCRIPT_DIRECTORY=${ROOT_DIRECTORY}/scripts  # Remote instance
NATS_OPERATOR=""
NATS_USER_ACCOUNT=""
NATS_USER=""
NATS_URL=""
NATS_SERVER_NAME=""
NATS_WEBSOCKET_PORT=""
# Internal Variables
NKEYS_PATH=~/.local/share/nats/nsc/keys
NATS_BIN=/usr/bin/nats-server
NATSCLI_BIN=/usr/bin/nats
NSC_BIN=/usr/bin/nsc
NATS_HOME=/mnt/disks/nats_home
NATS_RESOLVER=resolver.conf
NATS_CONF=nats.conf
NATS_PID=nats.pid
NATS_PID_RUNNING=nats.pid.running

function initScript() {
  . "${SCRIPT_DIRECTORY}"/echo-colors.sh
}

function displaySavup() {
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

function displayWarning() {
  echo -e "${BLACK}${ON_YELLOW}WARNING: $1${COLOR_OFF}"
}

function displayStepSpacer() {
	echo "--------------------------"
}

function displaySkipMessage() {
  if [[ ( "$1" == "Y" ) || ( "$1" == "y" ) ]]; then
    echo -e " Do you want to ${BLACK}${ON_YELLOW}SKIP${COLOR_OFF} this step? (${BLACK}${ON_YELLOW}Y${COLOR_OFF}/n)"
  else
    echo -e " Do you want to ${BLACK}${ON_YELLOW}SKIP${COLOR_OFF} this step? (y/${BLACK}${ON_YELLOW}N${COLOR_OFF})"
  fi
}

function isNATSAlreadyRunning() {
  sudo ps aux | grep nats-server | awk '/nats.conf/' > /tmp/natsAUX.tmp
  NATS_PID=$(sudo cat /tmp/natsAUX.tmp | awk '//{print $2}')

  if [[ -n "$NATS_PID" ]]; then
   	displayAlert
    	echo -e "${ON_RED} A NATS Server is already running on this system.${COLOR_OFF}"
    	echo
    	echo -e "${ON_RED} Please investigate the configuration of this system.${COLOR_OFF}"
    	echo
    	echo -e "${ON_RED} NATS PID:${COLOR_OFF} $NATS_PID"
    	echo
    	echo -e "${ON_RED} You must stop NATS before this script will run.${COLOR_OFF}"
    	echo
    	echo -e "${ON_RED} run: kill -USR2 $NATS_PID${COLOR_OFF}"
    	echo
    	exit 1
  fi
}

function print_error() {
  echo -e "${ON_RED}$1${COLOR_OFF}"
}

function set_variable() {
  cmd="${1}=$2"
  eval "$cmd"
  cmd="${1}_CHECKED=\"true\""
  eval "$cmd"
}

function validate_parameters() {
  if [ -z "$NATS_OPERATOR_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The operator parameter is missing"
  fi
  if [ -z "$NATS_USER_ACCOUNT_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The user account parameter is missing"
  fi
  if [ -z "$NATS_USER_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The user parameter is missing"
  fi
  if [ -z "$NATS_URL_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The URL parameter is missing"
  fi
  if [ -z "$NATS_SERVER_NAME_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The server name parameter is missing"
  fi

  if [ "$Failed" == "true" ]; then
    print_usage
    exit 1
  fi
}

function restartSystem() {
  displayWarning "You are about to restart the instance!!"
  displaySkipMessage y
  read -r restart
  if [[ ( "$restart" == "N" ) || ( "$restart" == "n" ) ]]; then
  	sudo shutdown -r now
  	exit
  else
    echo "You elected to skip this step"
    echo
  fi
}

function removeNATS() {
  displayWarning "You are about to remove any existing NATS software from the instance!!"
  displaySkipMessage Y
  read -r continue
  if [[ ( "$continue" == "N" ) || ( "$continue" == "n" ) ]]; then
    sudo rm -rf "$NATS_HOME"/*
    sudo rm -rf "$NATS_HOME"/.keys
    sudo rm "$NATS_BIN"
   	sudo rm "$NATSCLI_BIN"
   	sudo rm "$NSC_BIN"
   	rm -rf "$HOME"/.config/NATS
   	rm -rf "$HOME"/.local/NATS
   	rm -rf "$HOME"/.local/share/nats
  else
    echo "You elected to skip this step"
  fi
  echo
}

function addNATSExport() {
  echo "Add NATS Exports to $HOME/.bash_exports"
  if grep -q "${NATS_URL}" "$HOME/.bash_exports"; then
  	echo " - NATS exports already exist. No action taken."
  else
  	cat >> "$HOME/.bash_exports" <<- EOF
export NATS_URL=$NATS_URL
export NATS_HOME=$NATS_HOME
EOF
    echo "- Appended NATS to the $HOME/.bash_exports"
  fi
    echo
}

function installNATSTools() {
  echo "Install NATS server, NATS CLI, and NSC at $NATS_HOME"
  displaySkipMessage n
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
  	sh "$HOME"/scripts/NATS-install-nats-natscli-nsc.sh "$1" "$2" "$3" "$4"
  fi
  echo
}

function createOperatorAndSystem() {
  echo "Creating NATS operator and SYS at ${NATS_URL}"
  displaySkipMessage N
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
  	sh "$HOME"/scripts/NATS-create-operator-sys.sh "$1" "$2" "$3" "$4" "$5"
  fi
}

function createAccount() {
  echo "Creating NATS SAVUP account"
  displaySkipMessage N
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
  	sh "$HOME"/scripts/NATS-create-account.sh "$1" "$2"
  fi
}

function createResolver() {
  echo "Creating NATS resolver file"
  displaySkipMessage N
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
  	sh "$HOME"/scripts/NATS-create-resolver-file.sh "$1" "$2" "$3"
#  	sh "$HOME"/scripts/NATS-edit-jwt-dir.sh "$1" "$2"
  fi
}

function createNATSServerConfig() {
    echo "NEXT: Creating NATS config file"
    echo
    echo " Do you want to SKIP this step? (Y/n)"
    echo "                ----"
    read continue
    if [ "$continue" == "n" ]; then
    	sh $HOME/NATS-1.4-create-config-file.sh
    fi
}

function startNATSServer() {
  echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  echo "==> XX WARNING - VERY IMPORTANT     XX"
  echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  echo
  echo "==> You are about to start the NATS server in background mode"
  echo "==>"
  echo "==>"
  echo " Do you want to SKIP this step? (Y/n)"
  echo "                ----"
  read continue
  if [ "$continue" == "n" ]; then
  	sh $HOME/NATS-1.5-start-server.sh &
  	sleep 2
  	sudo ps aux | grep nats-server | awk '/nats.conf/' > /tmp/natsAUX.tmp
  	NATS_PID=$(sudo cat /tmp/natsAUX.tmp | awk '//{print $2}')
  	if [[ -z "$NATS_PID" ]]; then
  		echo "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
  		echo "ZZ      SERVER DID NOT START        ZZ"
  		echo "ZZ           EXISTING               ZZ"
  		echo "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
  		exit
  	fi
  fi
}

function pushAllAccountsUser() {
  echo "NEXT: Pushing NSC account to NATS server"
  echo
  echo " Do you want to SKIP this step? (Y/n)"
  echo "                ----"
  read continue
  if [ "$continue" == "n" ]; then
  	sh $HOME/NATS-1.6-push-accounts.sh
  fi
}

function createUser() {
  echo "NEXT: Creating NATS savup user"
  echo
  echo " Do you want to SKIP this step? (Y/n)"
  echo "                ----"
  read continue
  if [ "$continue" == "n" ]; then
  	sh $HOME/NATS-1.7-create-savup-user.sh
  fi
}

function createContext() {
  echo "NEXT: Creating NATS contexts"
  echo
  echo " Do you want to SKIP this step? (Y/n)"
  echo "                ----"
  read continue
  if [ "$continue" == "n" ]; then
  	sh $HOME/NATS-1.7.1-create-contexts.sh
  fi
}

function cleanUp() {
  echo "NEXT: Clean up and next steps "
  echo
  echo " Do you want to SKIP this step? (Y/n)"
  echo "                ----"
  read continue
  if [ "$continue" == "n" ]; then
  	sh $HOME/NATS-1.9-cleanup.sh
  	echo
  	echo "==> Clean up is done"
  fi
}

# shellcheck disable=SC2028
function print_parameters() {
  echo "Here are the values you have supplied:"
  echo -e "NATS_OPERATOR:\t     ${NATS_OPERATOR}"
  echo -e "NATS_URL:\t     ${NATS_URL}"
  echo "NATS_SERVER_NAME:    ${NATS_SERVER_NAME}"
  if [ -z "${NATS_WEBSOCKET_PORT}" ]; then
    echo "NATS_WEBSOCKET_PORT: is not being used"
  else
    echo "NATS_WEBSOCKET_PORT: ${NATS_WEBSOCKET_PORT}"
  fi
  echo "NATS_USER_ACCOUNT:   ${NATS_USER_ACCOUNT}"
  echo -e "NATS_USER:\t     ${NATS_USER}"
  echo
  echo "Here are the pre-set or defined variables:"
  echo "ROOT_DIRECTORY:   ${ROOT_DIRECTORY}"
  echo "SCRIPT_DIRECTORY: ${SCRIPT_DIRECTORY}"
  echo
}

# shellcheck disable=SC2028
function print_usage() {
  echo
  echo "This will create an instance on GCloud."
  echo
  echo "Usage: ${FILENAME} -h | -o {operator name} -a {account name} -n {user name} -u {url} -s {server name} -p {port number}"
  echo
  echo "flags:"
  echo -e "  -h\t\t\t display help"
  echo -e "  -o {operator name}\t The name of the operator."
  echo -e "  -a {account name}\t The name of the starter account."
  echo -e "  -n {user name}\t The name of the starter user."
  echo -e "  -u {url}\t\t The URL for the server. This has to be set up in DNS or the host file."
  echo -e "  -s {server name}\t The instance name of the server."
  echo -e "  -p {port number}\t Optional - Websocket port number. Recommended to use 9222"
  echo
}

# Main function of this script
function runScript {
  if [ "$#" == "0" ]; then
    print_error "ERROR: No parameters where provided."
    print_usage
    exit 1
  fi

  displaySavup
  isNATSAlreadyRunning

  while getopts 'o:a:u:n:s:w:h' OPT; do # see print_usage
    case "$OPT" in
    o)
      set_variable NATS_OPERATOR "$OPTARG"
      ;;
    n)
      set_variable NATS_USER "$OPTARG"
      ;;
    s)
      set_variable NATS_SERVER_NAME "$OPTARG"
      ;;
    p)
      set_variable NATS_WEBSOCKET_PORT "$OPTARG"
      ;;
    a)
      set_variable NATS_USER_ACCOUNT "$OPTARG"
      ;;
    u)
      set_variable NATS_URL "$OPTARG"
      ;;
    h)
      print_usage
      exit 0
      ;;
    *)
      print_error "${ON_RED}ERROR: Please review the usage printed below:${COLOR_OFF}" >&2
      print_usage
      exit 1
      ;;
    esac
  done

  validate_parameters
  print_parameters
  removeNATS
  restartSystem
  addNATSExport
  installNATSTools "$NATS_HOME" "$NATS_BIN" "$NATSCLI_BIN" "$NSC_BIN"
  createOperatorAndSystem "$NATS_OPERATOR" "$NATS_HOME" "$NATS_URL" "$NKEYS_PATH" "$SCRIPT_DIRECTORY"
  createAccount "$NATS_USER_ACCOUNT" "$SCRIPT_DIRECTORY"
  createResolver "$NATS_HOME" "$NATS_RESOLVER" "$SCRIPT_DIRECTORY"
#  createNATSServerConfig
#  startNATSServer
#  pushAllAccountsUser
#  createUser
#  createContext
#  cleanUp

  echo
  echo -e "${BLACK}${ON_GREEN}Post installation steps:${COLOR_OFF}"
  echo You will need to take a copy of this file:
  cat "$NATS_HOME"/SYS_SIGNED_KEY_LOCATION.nk
  echo and locate it so the SavUp server has access.
  echo
  echo "Done!"
}

initScript
runScript "$@"
