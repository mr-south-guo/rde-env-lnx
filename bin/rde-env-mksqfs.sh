#!/bin/bash

SCRIPTFULLPATH=$( readlink -f "$BASH_SOURCE" )
THIS=${SCRIPTFULLPATH##*/}
RDE_ENV_BINPATH=${SCRIPTFULLPATH%/*}
. "${RDE_ENV_BINPATH}/rde-env-subs.sh"

HELP_MSG="\
RDE-Env Utility: Make a SquashFs file
Usage:
${THIS} -h 
${THIS} -i <input> -o <output>

Options:
    -h           This help message
    -i <input>   The input directory
    -o <output>  The output squashfs file
"

while getopts ':hi:o:' option; do
  case "$option" in
    h) echo "${HELP_MSG}"
       exit
       ;;
    i) INPUT_DIR=$( readlink -f "$OPTARG" )
       ;;
    o) IMAGE_FILE=$( readlink -f "$OPTARG" )
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

if [ -z "${IMAGE_FILE}" ] || [ -z "${INPUT_DIR}" ]; then
    log_msg "[ERR] Not enough options"
    echo "${HELP_MSG}"
    exit
fi

if [ -e ${IMAGE_FILE} ]; then
  log_msg "[ERR] ${IMAGE_FILE} already exists. Abort!"
  exit 1
fi

mksquashfs "${INPUT_DIR}" "${IMAGE_FILE}" -comp xz

