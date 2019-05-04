#!/bin/bash

CIFS_SHARE="//10.0.2.2/rde-lnx-host"
MOUNT_POINT="/host"

exit_code=0

# Check if the directory is a mountpoint
if mountpoint -q "${MOUNT_POINT}"; then
  echo "[ERR] ${MOUNT_POINT} is another mountpoint. Abort mounting!"
  exit_code=1
else
  echo "[INF] Going to mount ${CIFS_SHARE} to ${MOUNT_POINT}."
  sudo mount -t cifs "${CIFS_SHARE}" "${MOUNT_POINT}"
fi

read -p "Press [Enter] key to continue..."
exit ${exit_code}
