#!/bin/bash

SCRIPTFULLPATH=$( readlink -f "$BASH_SOURCE" )
THIS=${SCRIPTFULLPATH##*/}
. "${SCRIPTFULLPATH%/*}/rde-subs.sh"

HELP_MSG="\
RDE Utility: Make a tmpfs ramdisk
Usage:
${THIS} -h 
${THIS} -s <size> -m <mountpoint>

Options:
    -h              This help message
    -s <size>       Size of the ramdisk. Can use k,M,G as unit
    -m <mountpoint> Where to mount the ramdisk. Will be created automatically.\
"

while getopts ':hs:m:' option; do
  case "$option" in
    h) echo "${HELP_MSG}"
       exit
       ;;
    s) IMAGE_FILE_SIZE=$OPTARG
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

if [ -z "${IMAGE_FILE_SIZE}" ] || [ -z "${MOUNT_POINT}" ]; then
    log_msg "[ERR] Not enough options"
    echo "${HELP_MSG}"
    exit
fi

Sub_PrepareEmptyDir "${MOUNT_POINT}"
Sub_IfErrExit

sudo mount -t tmpfs tmpfs "${MOUNT_POINT}" -o defaults,size=${IMAGE_FILE_SIZE}
