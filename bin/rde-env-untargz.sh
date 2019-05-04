#!/bin/bash

TARGZ_FILE=$( readlink -f "$1" )
EXTRACT_DIR=$( readlink -f "$2" )

SCRIPTFULLPATH=$( readlink -f "$BASH_SOURCE" )
RDE_ENV_BINPATH=${SCRIPTFULLPATH%/*}
. "${RDE_ENV_BINPATH}/rde-env-subs.sh"

Sub_PrepareEmptyDir "${EXTRACT_DIR}"
if [ $? -gt 0 ]; then
  log_msg "[INF] Aborted."
  exit $?
fi

log_msg "[INF] Extraction begins."
tar -xzf ${TARGZ_FILE} -C ${EXTRACT_DIR} --checkpoint=.100
echo ""
log_msg "[INF] Extraction completed."
