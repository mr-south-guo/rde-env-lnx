#!/bin/echo *** This script should only be sourced, e.g.: . 

###
# Activate/Deactivate script for RDE-Env App
# version: 1.0
# - To enable corresponding app: copy this script to <root>/env/<env-name>/.enable/
# - The following variables are provided by the caller script:
#    - ${RDE_APP_MOUNT_ROOT} : the common root all this env's apps may be mount to
#    - ${RDE_ENV_LIB} : the <root>/lib/ directory where all apps' files located
###

RDE_APP_NAME=misc
RDE_APP_SUFFIX=this-env
RDE_APP_MOUNT_POINT=${RDE_ENV_HOME}
RDE_APP_SRC_DIR=${RDE_ENV_LIB}/${RDE_APP_NAME}/${RDE_APP_SUFFIX}

case "${RDE_ENV_ACTION}" in
  activate)
    Sub_ProcessDesktop
    Sub_AppendToSetEnvFile "
## Misc: this-env
# These two variables are used by deactivate action.
# Setting them here to avoid \$HOME change.
export RDE_ENV_DESKTOP_DIR1=${RDE_ENV_DESKTOP_DIR1}
export RDE_ENV_DESKTOP_DIR2=${RDE_ENV_DESKTOP_DIR2}
"
    ;;
  deactivate)
    echo "Nothing to do." > /dev/null
    ;;
  *)
    log_msg "[WRN] I don't understand: RDE_ENV_ACTION=${RDE_ENV_ACTION}"
    ;;
esac
