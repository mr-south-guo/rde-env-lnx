#!/bin/echo *** This script should only be sourced, e.g.: . 

# Sub-routines for RDE-Env
# Version: 1.0

# This script depends on `rde-subs.sh`
SCRIPTFULLPATH=$( readlink -f "$BASH_SOURCE" )
RDE_ENV_BINPATH=${SCRIPTFULLPATH%/*}
. "${RDE_ENV_BINPATH}/rde-subs.sh"

Sub_ProcessDesktop() {
  local DESKTOP_TMP_DIR=$( mktemp -d -p /dev/shm rde-env-desktop-tmp-XXX )

  # Check if there are *.desktop files in the ${RDE_APP_SRC_DIR}
  if [ 0 -lt $(ls "${RDE_APP_SRC_DIR}"/*.desktop 2>/dev/null | wc -w) ]; then
    # Yes. Create a temp directory and copy those desktop files there.
    # mkdir -p ${DESKTOP_TMP_DIR}
    cp "${RDE_APP_SRC_DIR}"/*.desktop "${DESKTOP_TMP_DIR}"/

    # Prepend ${RDE_ENV_NAME}.
    sed -i -e "s,^Name=,Name=(${RDE_ENV_NAME}) ," "${DESKTOP_TMP_DIR}"/*.desktop

    # Prepend ${RDE_APP_MOUNT_POINT}. `TryExec` key is for checking only.
    sed -i -e "s,^TryExec\(=./\|=/\|=\)\(.*\),TryExec=${RDE_APP_MOUNT_POINT}/," "${DESKTOP_TMP_DIR}"/*.desktop

    # Source the ${RDE_ENV_SETENV_FILE} first, and prepend ${RDE_APP_MOUNT_POINT} to the executable.
    sed -i -e "s,^Exec\(=./\|=/\|=\)\(.*\),Exec=/bin/bash -c \". ${RDE_ENV_SETENV_FILE}; ${RDE_APP_MOUNT_POINT}/\2\"," "${DESKTOP_TMP_DIR}"/*.desktop

    # Prepend ${RDE_APP_MOUNT_POINT} to the icon file.
    sed -i -e "s,^Icon\(=./\|=/\|=\),Icon=${RDE_APP_MOUNT_POINT}/," "${DESKTOP_TMP_DIR}"/*.desktop

    # Copy the processed desktop files to Desktop and clean up the temp directory.
    cp "${DESKTOP_TMP_DIR}"/*.desktop "${RDE_ENV_DESKTOP_DIR1}"/
    cp "${DESKTOP_TMP_DIR}"/*.desktop "${RDE_ENV_DESKTOP_DIR2}"/
    rm -r "${DESKTOP_TMP_DIR}"
  fi
}

# Run all the APPs' setup script
Sub_SetAllApps() {
  log_msg "[WRN] This action requires administrator privilege."
  sudo echo "--- sudo ---" > /dev/null

  for a in ${RDE_ENV_HOME}/.enable/APP_*.sh; do
    [ -e "$a" ] || continue
    log_msg "[INF] ${a##*/}"
    . "${a}"
  done
}

Sub_SetSetEnvFile() {
  RDE_ENV_SETENV_FILE=${RDE_ENV_HOME}/bin/rde-env-setenv.sh
}

Sub_AppendToSetEnvFile() {
  echo -e "$1" >> ${RDE_ENV_SETENV_FILE}
}

Sub_Mount() {
  local MOUNT_SOURCE=$1
  local MOUNT_POINT=$2
  local OPT_FORCE=$3

  # Check if the source exists.
  if [ ! -e "${MOUNT_SOURCE}" ]; then
    log_msg "[ERR] ${MOUNT_SOURCE} does not exists! Abort mounting."
    return 1
  fi

  Sub_PrepareEmptyDir "${MOUNT_POINT}"
  if [ $? -gt 0 ] && [ -z "${OPT_FORCE}" ]; then
    log_msg "[ERR] Aborted."
    return 1
  fi

  # Mount!
  if [ -d "${MOUNT_SOURCE}" ]; then
    sudo mount --bind "${MOUNT_SOURCE}" "${MOUNT_POINT}"
  else
      local FILE_NAME=$(basename -- "${MOUNT_SOURCE}")
      local FILE_EXT="${FILE_NAME##*.}"

      case ${FILE_EXT} in
        sqfs) sudo mount -t squashfs "${MOUNT_SOURCE}" "${MOUNT_POINT}" -o exec
        ;;
        btrfs) sudo mount -t btrfs "${MOUNT_SOURCE}" "${MOUNT_POINT}" -o exec,rw,noatime,compress=zstd
        ;;
        *) echo "Unknown file extension: ${FILE_NAME}"
        return 1
        ;;
      esac
  fi
  return $?
}

Sub_KillByPattern() {
  local PATTERN=$1
	
  local CMD_STRING="pgrep -f ${PATTERN}"
  if ${CMD_STRING} &> /dev/null; then
    log_msg "[WRN] - Terminating processes running from '${PATTERN}'"
    pkill -f ${PATTERN}
    sleep 0.5
    while ${CMD_STRING} &> /dev/null; do
      sleep 0.5
    done
  fi
  
  CMD_STRING="lsof -t ${PATTERN}"
  if ${CMD_STRING} &> /dev/null; then
    log_msg "[WRN] - Terminating processes opening '${PATTERN}'"
    kill `${CMD_STRING}`
    sleep 0.5
    while ${CMD_STRING} &> /dev/null; do
      sleep 0.5
    done
  fi
}

Sub_Unmount() {
  local MOUNT_POINT=$1

  # Check if the directory is a mountpoint
  if mountpoint -q "${MOUNT_POINT}"; then
    sudo umount "${MOUNT_POINT}"
    sudo rmdir "${MOUNT_POINT}"
  else
    log_msg "[WRN] ${MOUNT_POINT} is not a mountpoint. No need to unmount."
  fi
}

