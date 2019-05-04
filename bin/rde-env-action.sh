#!/bin/bash

## Setup environment
## $1 - The title of the RDE-ENV
## $2 - The HOME directory of the RDE-ENV
## $3 - Action: enable, disable, terminal

SCRIPTFULLPATH=$( readlink -f "$BASH_SOURCE" )
RDE_ENV_BINPATH=${SCRIPTFULLPATH%/*}
. "${RDE_ENV_BINPATH}/rde-env-subs.sh"

# Set some basic RDE-ENV level variables
RDE_ENV_HOME=$1
RDE_ENV_ACTION=$2
RDE_ENV_LIB=$( readlink -f "${RDE_ENV_HOME}/../../lib" )
export PATH=${RDE_ENV_BINPATH}:${RDE_ENV_HOME}/bin:${PATH}
Sub_SetSetEnvFile

# Apply config for the current RDE-ENV (may override above variables)
. ${RDE_ENV_HOME}/etc/rde-env.conf

case "${RDE_ENV_ACTION}" in
  activate)
    Sub_SetXTermTitle "${RDE_ENV_NAME}:${RDE_ENV_ACTION}"
    Sub_EchoHeading1 "${RDE_ENV_NAME}" "${RDE_ENV_ACTION}"
    if [ -e "${RDE_ENV_SETENV_FILE}" ]; then
      rm "${RDE_ENV_SETENV_FILE}"
    fi
    mkdir -p "${HOME}/Desktop/${RDE_ENV_NAME}"
    Sub_SetAllApps
    ;;
  deactivate)
    Sub_SetXTermTitle "${RDE_ENV_NAME}:${RDE_ENV_ACTION}" 
    Sub_EchoHeading2 "${RDE_ENV_NAME}" "${RDE_ENV_ACTION}"
    Sub_SetAllApps
    rm "${RDE_ENV_SETENV_FILE}"
    rm -r "${HOME}/Desktop/${RDE_ENV_NAME}"
    ;;
  terminal)
    RDE_SHELL_RC="\
    source ~/.bashrc;\
    export PS1=\"${RDE_ENV_PROMPT}\";\
    echo -ne \"\033]0;${RDE_ENV_NAME}\007\"\
    "
    if [ -e ${RDE_ENV_SETENV_FILE} ]; then
      RDE_SHELL_RC="${RDE_SHELL_RC};source \"${RDE_ENV_SETENV_FILE}\""
    else
      log_msg "[WRN] ${RDE_ENV_SETENV_FILE} does not exist. Not yet activated?"
    fi
  
    # Start a new bash shell.
    /bin/bash --rcfile <(echo ${RDE_SHELL_RC})
    ;;
  *)
    log_msg "[ERR] I don't understand: RDE_ENV_ACTION=${RDE_ENV_ACTION}"
    ;;
esac

read -p "Press [Enter] key to continue..."

