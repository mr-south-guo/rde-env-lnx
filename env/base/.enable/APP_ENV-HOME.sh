#!/bin/echo *** This script should only be sourced, e.g.: . 

RDE_APP_MOUNT_POINT=${RDE_ENV_HOME}
RDE_APP_SRC_DIR=${RDE_ENV_HOME}/desktop

case "${RDE_ENV_ACTION}" in
  activate)
    Sub_ProcessDesktop
    ;;
  deactivate)
    echo "Nothing to do." > /dev/null
    ;;
  *)
    log_msg "[WRN] I don't understand: RDE_ENV_ACTION=${RDE_ENV_ACTION}"
    ;;
esac
