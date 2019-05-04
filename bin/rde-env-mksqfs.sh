#!/bin/bash

SOURCE_DIR=$( readlink -f "$1" )
IMAGE_FILE=$( readlink -f "$2" )

SCRIPTFULLPATH=$( readlink -f "$BASH_SOURCE" )
RDE_ENV_BINPATH=${SCRIPTFULLPATH%/*}
. "${RDE_ENV_BINPATH}/rde-env-subs.sh"

if [ -e ${IMAGE_FILE} ]; then
  log_msg "[ERR] ${IMAGE_FILE} already exists!"
  log_msg "[INF] Aborted."
  exit 1
fi

mksquashfs "${SOURCE_DIR}" "${IMAGE_FILE}" -comp xz
