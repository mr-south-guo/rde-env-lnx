#!/bin/bash

SCRIPTFULLPATH=$( readlink -f "$BASH_SOURCE" )
THIS=${SCRIPTFULLPATH##*/}
RDE_ENV_BINPATH=${SCRIPTFULLPATH%/*}
. "${RDE_ENV_BINPATH}/rde-env-subs.sh"

HELP_MSG="\
RDE-Env Utility: Untar a tar.gz file
Usage:
${THIS} -h 
${THIS} -i <input> -o <output>

Options:
    -h           This help message
    -i <input>   The input tar.gz file
    -o <output>  The output directory
"

while getopts ':hi:o:' option; do
  case "$option" in
    h) echo "${HELP_MSG}"
       exit
       ;;
    i) INPUT_PATH=$( readlink -f "$OPTARG" )
       ;;
    o) OUTPUT_PATH=$( readlink -f "$OPTARG" )
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

if [ -z "${INPUT_PATH}" ] || [ -z "${OUTPUT_PATH}" ]; then
    log_msg "[ERR] Not enough options"
    echo "${HELP_MSG}"
    exit
fi

# Check if the directory exists.
if [ -e "${OUTPUT_PATH}" ]; then
  # Yes. Then check if the directory is empty.
  if find ${OUTPUT_PATH}/ -maxdepth 0 -empty | read v; then
    log_msg "[WRN] ${OUTPUT_PATH} exists but empty."
  else
    log_msg "[ERR] ${OUTPUT_PATH} exists and is NOT empty."
    exit 1
  fi
else
  mkdir -p "${OUTPUT_PATH}"
fi

log_msg "[INF] Extraction begins."
tar -xzf ${INPUT_PATH} -C ${OUTPUT_PATH} --checkpoint=.100
echo ""
log_msg "[INF] Extraction completed."

