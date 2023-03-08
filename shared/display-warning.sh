#!/bin/bash
#
# This is reusable code for displaying a warning message
#

# shellcheck disable=SC2129
displayWarning() {
  echo -e "${BLACK}${ON_YELLOW}WARNING: $1${COLOR_OFF}"
}

