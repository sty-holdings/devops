#!/bin/bash
#
# Name: install-0-config-instance.sh
#
# Description: Copy the 0-config-instance.sh to the target gcloud instance.
#
# Installation:
#   None required
#
# Copyright (c) 2022 STY-Holdings Inc
# All Rights Reserved
#

set -eo pipefail

SOURCE_FILE=/Users/syacko/workspace/styh-dev/devops/0-config-instance.sh
TARGET_LOCATION=/home/scott_yacko_sty_holdings_com/styh/scripts
GC_SERVER_USER="scott_yacko_sty_holdings_com"
GC_INSTANCE_NAME="savup-dev-1"
GC_REGION="us-central1-c"
GC_ENVIRONMENT=""

function display_savup() {
	echo
	echo "======================================"
	echo "   SSSS    AA    V    V  U   U  PPPP  "
	echo "  S       A  A   V    V  U   U  P   P "
	echo "   SSS    AAAA    V  V   U   U  PPPP  "
	echo "      S  A    A   V  V   U   U  P     "
	echo "  SSSS   A    A    VV     UUU   P     "
	echo "======================================"
}

function display_production() {
	echo "  PRODUCTION  "
	echo "  PRODUCTION  "
	echo "  PRODUCTION  "
	echo "  PRODUCTION  "
	echo "  PRODUCTION  "
	echo "=============="
	echo
}

function display_development() {
	echo "   Development  "
	echo "   Development  "
	echo "================"
	echo
}

function run_gcloud_cmds() {
  echo "Running GCloud Commands"
  gcloud config set project ${GC_ENVIRONMENT}
  gcloud compute ssh --zone ${GC_REGION} ${GC_SERVER_USER}@${GC_INSTANCE_NAME} --command "mkdir -p ${TARGET_LOCATION}"
  gcloud compute scp --recurse --zone ${GC_REGION} ${SOURCE_FILE} ${GC_SERVER_USER}@${GC_INSTANCE_NAME}:${TARGET_LOCATION}/.
  gcloud compute ssh --zone ${GC_REGION} ${GC_SERVER_USER}@${GC_INSTANCE_NAME} --command "chmod 700 ${TARGET_LOCATION}/*"
  echo "File has been copied to GCloud instance"
}

function print_usage() {
  echo
  echo "This will install the 0-config-instance.sh script for the defined GCloud instance."
  echo
  echo "Usage: install-0-config-instance.sh [option]"
  echo
  echo "Options:"
  echo -e "  --help-h\tdisplay help"
  echo -e "  --development|-d\tRun for a gcloud development instance"
  echo -e "  --productioin|-p\tRun for a gcloud production instance"
  echo
}


# Main function of this script
function run_script {
  display_savup

  key="$1"

  if [[ -z "$key" ]]; then
    echo "ERROR: A argument must be provided."
    print_usage
    exit 1
  fi

  while [[ "$#" -gt 0 ]]; do
    case $key in
      --development|-d)
        GC_ENVIRONMENT=savup-development
        display_development
        run_gcloud_cmds
        ;;
      --help|-h)
        print_usage
        ;;
      --production|-p)
        GC_ENVIRONMENT=savup-f3343
        display_production
        run_gcloud_cmds
        ;;
      *)
       	print_usage
       	exit 1
    esac
    shift
  done
}

run_script "$@"
