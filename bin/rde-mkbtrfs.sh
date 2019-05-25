#!/bin/bash

SCRIPTFULLPATH=$( readlink -f "$BASH_SOURCE" )
THIS=${SCRIPTFULLPATH##*/}
. "${SCRIPTFULLPATH%/*}/rde-subs.sh"

HELP_MSG="\
RDE Utility: Make a BTRFS Partition file
Usage:
${THIS} -h 
${THIS} -f <filename> -s <size> -l <label> -m <mountpoint>

Options:
    -h              This help message
    -f <filename>   The BTRFS partition file
    -s <size>       Size of the file. Can use k,M,G as unit
    -l <label>      Label of the BTFS partition
    -m <mountpoint> Where to mount the file. Will be created automatically.\
"

while getopts ':hf:s:l:m:' option; do
  case "$option" in
    h) echo "${HELP_MSG}"
       exit
       ;;
    f) IMAGE_FILE=$( readlink -f "$OPTARG" )
       ;;
    s) IMAGE_FILE_SIZE=$OPTARG
       ;;
    l) IMAGE_FILE_LABEL=$OPTARG
       ;;
    m) MOUNT_POINT=$( readlink -f "$OPTARG" )
       ;;
    :) log_msg "[ERR] Missing argument for -${OPTARG}"
       echo "${HELP_MSG}"
       exit 1
       ;;
   \?) log_msg "[ERR] Illegal option: -${OPTARG}"
       echo "${HELP_MSG}"
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

if [ -z "${IMAGE_FILE}" ] || [ -z "${IMAGE_FILE_SIZE}" ] || [ -z "${IMAGE_FILE_LABEL}" ] || [ -z "${MOUNT_POINT}" ]; then
    log_msg "[ERR] Not enough options"
    echo "${HELP_MSG}"
    exit
fi

if [ -e ${IMAGE_FILE} ]; then
  log_msg "[ERR] ${IMAGE_FILE} already exists. Abort!"
  exit 1
fi

log_msg "[INF] Creating mount point '${MOUNT_POINT}'"
Sub_PrepareEmptyDir "${MOUNT_POINT}"
Sub_IfErrExit

log_msg "[INF] Creating sparse file '${IMAGE_FILE}' of size ${IMAGE_FILE_SIZE}"
dd if=/dev/zero of="${IMAGE_FILE}" bs=1 count=0 seek=${IMAGE_FILE_SIZE}
Sub_IfErrExit

log_msg "[INF] Creating btrfs filesystem on '${IMAGE_FILE}' with label '${IMAGE_FILE_LABEL}'"
mkfs.btrfs --mixed -L "${IMAGE_FILE_LABEL}" "$IMAGE_FILE"
Sub_IfErrExit

log_msg "[INF] Mounting '${IMAGE_FILE}' to '${MOUNT_POINT}'"
sudo mount -t btrfs -o rw,noatime,exec,compress-force=zstd "${IMAGE_FILE}" "${MOUNT_POINT}"
Sub_IfErrExit

log_msg "[INF] Changing owner of '${MOUNT_POINT}' to '${USER}:${USER}'"
sudo chown ${USER}:${USER} "${MOUNT_POINT}"
Sub_IfErrExit
