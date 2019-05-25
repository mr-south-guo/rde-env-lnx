#!/bin/bash

RSYNC_CMD="rsync -axHXS --info=progress2"

if [ $# -eq 0 ]; then
  echo "\
This is a very simple wrapper script for rsync:
${RSYNC_CMD} [arguments to this script]
"
  exit
fi

eval ${RSYNC_CMD} $@
