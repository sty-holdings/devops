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
set -o pipefail

# script variables
# shellcheck disable=SC2006
FILENAME=$(basename "$0")
# Directory and files
ROOT_DIRECTORY=/home/scott_yacko_sty_holdings_com # Remote instance
SCRIPT_DIRECTORY=${ROOT_DIRECTORY}/scripts  # Remote instance
NATS_OPERATOR=""
NATS_USER_ACCOUNT=""
NATS_USER=""
NATS_SERVER_NAME=""
NATS_WEBSOCKET_PORT=""
# Internal Variables
NATS_URL="nats://0.0.0.0:4222"
NKEYS_PATH=~/.local/share/nats/nsc/keys
NATS_BIN=/usr/bin/nats-server
NATSCLI_BIN=/usr/bin/nats
NSC_BIN=/usr/bin/nsc
NATS_HOME=/mnt/disks/nats_home
NATS_RESOLVER=resolver.conf
NATS_CONF_NAME=nats.conf
NATS_PID=nats.pid
NATS_PID_RUNNING=nats.pid.running

function initScript() {
  rm  "${NATS_HOME}"/NATS_log_file 2> /dev/null
  . "${SCRIPT_DIRECTORY}"/echo-colors.sh
  . "${SCRIPT_DIRECTORY}"/display-info.sh
  . "${SCRIPT_DIRECTORY}"/display-warning.sh
  . "${SCRIPT_DIRECTORY}"/display-error.sh
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

function displaySkipMessage() {
  if [[ ( "$1" == "Y" ) || ( "$1" == "y" ) ]]; then
    echo -e " Do you want to ${BLACK}${ON_YELLOW}SKIP${COLOR_OFF} this step? (${BLACK}${ON_YELLOW}Y${COLOR_OFF}/n)"
  else
    echo -e " Do you want to ${BLACK}${ON_YELLOW}SKIP${COLOR_OFF} this step? (y/${BLACK}${ON_YELLOW}N${COLOR_OFF})"
  fi
}

function isNATSAlreadyRunning() {
  displayInfo "Checking to see if NATS server is running."
  sudo ps aux | grep nats-server | awk '/nats.conf/' > /tmp/natsAUX.tmp
  NATS_PID=$(sudo cat /tmp/natsAUX.tmp | awk '//{print $2}')

  if [[ -n "$NATS_PID" ]]; then
    displayWarning "A NATS Server is already running on this system!!"
    displayWarning "Please investigate the configuration of this system."
   	echo "NATS PID: $NATS_PID"
   	echo
   	displayWarning "You must stop NATS before this script will run."
   	echo "run: sudo systemctl stop nats or kill -USR2 $NATS_PID"
   	echo
   	exit 1
  fi
}

function setVariable() {
  cmd="${1}=$2"
  eval "$cmd"
  cmd="${1}_CHECKED=\"true\""
  eval "$cmd"
}

function validateParameters() {
  if [ -z "$NATS_OPERATOR_CHECKED" ]; then
    local Failed="true"
    displayError "The operator parameter is missing"
  fi
  if [ -z "$NATS_USER_ACCOUNT_CHECKED" ]; then
    local Failed="true"
    displayError "The user account parameter is missing"
  fi
  if [ -z "$NATS_USER_CHECKED" ]; then
    local Failed="true"
    displayError "The user parameter is missing"
  fi
  if [ -z "$NATS_SERVER_NAME_CHECKED" ]; then
    local Failed="true"
    displayError "The server name parameter is missing"
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
   	sudo rm /tmp/nats*
   	rm -rf "$HOME"/.config/NATS
   	rm -rf "$HOME"/.local/NATS
   	rm -rf "$HOME"/.local/share/nats
   	rm -rf "$HOME"/.config/nats
  else
    echo "You elected to skip this step"
  fi
  echo
}

function addNATSExportAndDirectories() {
  displayInfo "Add NATS Exports to $HOME/.bash_exports."
  if grep -q "${NATS_URL}" "$HOME/.bash_exports"; then
  	echo " - NATS exports already exist. No action taken."
  else
  	cat >> "$HOME/.bash_exports" <<- EOF
export NATS_HOME=$NATS_HOME
EOF
    echo "- Appended NATS to the $HOME/.bash_exports"
  fi
  if [ -f "$NATS_HOME"/.keys ]; then
    echo "   - $NATS_HOME/.keys already exists. No action taken."
  else
    mkdir -p "$NATS_HOME"/.keys
    sudo chgrp nats "$NATS_HOME"/.keys
    sudo chmod 755 "$NATS_HOME"/.keys
  fi
  if [ -f "$NATS_HOME"/.certs ]; then
    echo "   - $NATS_HOME/.certs already exists. No action taken."
  else
    mkdir -p "$NATS_HOME"/.certs
    sudo chgrp nats "$NATS_HOME"/.certs
    sudo chmod 755 "$NATS_HOME"/.keys
  fi

    echo
}

function installNATSTools() {
  displayInfo "Install NATS server, NATS CLI, and NSC at $NATS_HOME"
  displaySkipMessage n
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
  	. "$HOME"/scripts/NATS-install-nats-natscli-nsc.sh "$1" "$2" "$3" "$4"
  fi
  echo
}

function createOperatorAndSystem() {
  displayInfo "Create NATS operator and SYS at ${NATS_URL}"
  displaySkipMessage N
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
  	. "$HOME"/scripts/NATS-create-operator-sys.sh "$1" "$2" "$3" "$4" "$5"
  fi
}

function createAccount() {
  displayInfo "Create NATS SAVUP account"
  displaySkipMessage N
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
  	. "$HOME"/scripts/NATS-create-account.sh "$1" "$2"
  fi
}

function createResolver() {
  displayInfo "Create NATS resolver file"
  displaySkipMessage N
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
  	. "$HOME"/scripts/NATS-create-resolver-file.sh "$1" "$2" "$3"
  	. "$HOME"/scripts/NATS-edit-jwt-dir.sh "$1" "$2"
  fi
}

function createNATSServerConfig() {
  displayInfo "Create NATS config file"
  displaySkipMessage N
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
    	. "$HOME"/scripts/NATS-create-config-file.sh "$1" "$2" "$3" "$4" "$5"
    fi
}

function startNATSServer() {
  displayInfo "Start the NATS server in background mode"
  displaySkipMessage N
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
  	. "$HOME"/scripts/NATS-start-server-service.sh "$1" "$2" "$3"
  	sleep 2
  	sudo ps aux | grep nats-server | awk '/nats.conf/' > /tmp/natsAUX.tmp
  	NATS_PID=$(sudo cat /tmp/natsAUX.tmp | awk '//{print $2}')
  	if [[ -z "$NATS_PID" ]]; then
  		displayWarning
  		displayWarning " SERVER DID NOT START "
  		exit
  	fi
  fi
}

function pushAllAccountsUser() {
  displayInfo "Push NSC account to NATS server"
  displaySkipMessage N
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
  	. "$HOME"/scripts/NATS-push-accounts.sh "$1" "$2"
  fi
}

function createUser() {
  displayInfo "Create NATS user"
  displaySkipMessage N
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
  	. "$HOME"/scripts/NATS-create-user.sh "$1" "$2" "$3" "$4"
  fi
}

function createContext() {
  displayInfo "Create NATS context for local user"
  displaySkipMessage N
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
  	. "$HOME"/scripts/NATS-create-SYS-contexts.sh "$1" "$2" "$3"
  	. "$HOME"/scripts/NATS-create-contexts.sh "$1" "$2" "$3" "$4" "$5"
  fi
}

function cleanUp() {
  displayInfo "Cleaning up"
  displaySkipMessage N
  read -r continue
  if  [[ ( "$continue" == "Y" ) || ( "$continue" == "y" ) ]]; then
    echo "You elected to skip this step"
    echo
  else
  	. "$HOME"/scripts/NATS-cleanup.sh
  	echo
  	echo "==> Clean up is done"
  fi
}

# shellcheck disable=SC2028
function printParameters() {
  displayInfo "Here are the values you have supplied:"
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
function printUsage() {
  displayInfo "This will create an instance on GCloud."
  echo
  echo "Usage: ${FILENAME} -h | -o {operator name} -a {account name} -n {user name} -s {server name} -p {port number}"
  echo
  echo "flags:"
  echo -e "  -h\t\t\t display help"
  echo -e "  -o {operator name}\t The name of the operator."
  echo -e "  -a {account name}\t The name of the starter account."
  echo -e "  -n {user name}\t The name of the starter user."
  echo -e "  -s {server name}\t The instance name of the server."
  echo -e "  -p {port number}\t Optional - Websocket port number. Recommended to use 9222"
  echo
}

# Main function of this script
function runScript {
  if [ "$#" == "0" ]; then
    displayError "No parameters where provided."
    printUsage
    exit 1
  fi

  displaySavup
  isNATSAlreadyRunning

  while getopts 'o:a:n:s:w:p:h' OPT; do # see print_usage
    case "$OPT" in
    o)
      setVariable NATS_OPERATOR "$OPTARG"
      ;;
    n)
      setVariable NATS_USER "$OPTARG"
      ;;
    s)
      setVariable NATS_SERVER_NAME "$OPTARG"
      ;;
    p)
      setVariable NATS_WEBSOCKET_PORT "$OPTARG"
      ;;
    a)
      setVariable NATS_USER_ACCOUNT "$OPTARG"
      ;;
    h)
      printUsage
      exit 0
      ;;
    *)
      displayError "Please review the usage printed below:" >&2
      printUsage
      exit 1
      ;;
    esac
  done

  validateParameters
  printParameters
  removeNATS
  restartSystem
  addNATSExportAndDirectories
  installNATSTools "$NATS_HOME" "$NATS_BIN" "$NATSCLI_BIN" "$NSC_BIN"
  createOperatorAndSystem "$NATS_OPERATOR" "$NATS_HOME" "$NATS_URL" "$NKEYS_PATH" "$SCRIPT_DIRECTORY"
  createAccount "$NATS_USER_ACCOUNT" "$SCRIPT_DIRECTORY"
  createResolver "$NATS_HOME" "$NATS_RESOLVER" "$SCRIPT_DIRECTORY"
  createNATSServerConfig "$NATS_HOME" "$NATS_WEBSOCKET_PORT" "$NATS_CONF_NAME" "$NATS_SERVER_NAME" "$NATS_RESOLVER"
  startNATSServer "$HOME" "$NATS_HOME" "$NATS_CONF_NAME"
  pushAllAccountsUser "$NATS_HOME" "$SCRIPT_DIRECTORY"
  createUser "$NATS_HOME" "$SCRIPT_DIRECTORY" "$NATS_USER_ACCOUNT" "$NATS_USER"
  createContext "$NATS_HOME" "$SCRIPT_DIRECTORY" "$NATS_OPERATOR" "$NATS_USER_ACCOUNT" "$NATS_USER"
  cleanUp

  echo
  displayInfo "Post installation steps:"
  echo "You will need to take a copy of this file:"
  cat "$NATS_HOME"/SYS_SIGNED_KEY_LOCATION.nk
  echo "  and locate it so the SavUp server has access."
  echo
  echo "Done!"
}

initScript
runScript "$@"
