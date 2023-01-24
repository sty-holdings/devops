#!/bin/bash

# Copy the 0-config-instance.sh to the target gcloud instance

SOURCE_FILE=/Users/syacko/workspace/styh-dev/devops/0-config-instance.sh
TARGET_LOCATION=/home/scott_yacko_sty_holdings_com/styh/scripts
GC_SERVER_USER="scott_yacko_sty_holdings_com"
GC_INSTANCE_NAME="savup-dev-1"
GC_REGION="us-central1-c"

displaySAVUP() {
	echo
	echo "======================================"
	echo "   SSSS    AA    V    V  U   U  PPP"
	echo "  S       A  A   V    V  U   U  P  P"
	echo "   SSS    AAAA    V  V   U   U  PPP"
	echo "      S  A    A   V  V   U   U  P"
	echo "  SSSS   A    A    VV     UUU   P"
	echo "======================================"
	echo
}

runGCloudCmds() {
  echo "Running GCloud Commands"
  gcloud config set project
  gcloud compute ssh --zone ${GC_REGION} ${GC_SERVER_USER}@${GC_INSTANCE_NAME} --command 'mkdir ${SERVER_LOCATION'
  gcloud compute scp --recurse --zone ${GC_REGION} ${SOURCE_FILE} ${GC_SERVER_USER}@${GC_INSTANCE_NAME}:${TARGET_LOCATION}/.
}

# Main function of this script
function run_script {
  while [[ "$#" > 0 ]]; do
    key="$1"
    shift
    case $key in
      --development|-d)
        echo "DEV"
        ;;
      --help|-h)
        echo "PROD"
        ;;
      --production|-p)
        print_usage
        ;;
      *)
       	print_usage
       	exit 1
    esac
    shift
  done

  assert_not_empty "Please provide alias area" $aliasArea

}

run_script "$@"

