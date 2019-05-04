#!/bin/echo *** This script should only be sourced, e.g.: . 

###
# Activate/Deactivate script for RDE-Env App
# - To enable this script: copy this script to <root>/env/<env-name>/.enable/
# - The following variables are provided by the caller script:
#    - ${RDE_APP_MOUNT_ROOT} : the common root all this env's apps may be mount to
#    - ${RDE_ENV_LIB} : the <root>/lib/ directory where all the apps' files located
###

RDE_APP_NAME=template
RDE_APP_SUFFIX=1.0

## The following path are recommended, but can be changed if needed

# Some apps require a fixed mount point (e.g. "/opt/app-name")
RDE_APP_MOUNT_POINT=${RDE_APP_MOUNT_ROOT}/${RDE_APP_NAME}-${RDE_APP_SUFFIX}

# This is where the *.desktop files located
RDE_APP_SRC_DIR=${RDE_ENV_LIB}/${RDE_APP_NAME}/${RDE_APP_SUFFIX}

# This is where the app's main body located
RDE_APP_IMAGE=${RDE_APP_SRC_DIR}/${RDE_APP_NAME}-${RDE_APP_SUFFIX}

case "${RDE_ENV_ACTION}" in
  activate)
    # The Sub_Mount handles:
    # - prepare "${RDE_APP_MOUNT_POINT}" (exists? empty?)
    # - mount the "${RDE_APP_IMAGE}" (btrfs, sqfs, or directory)
    # - add "--force" at the end to force mounting even if "${RDE_APP_MOUNT_POINT}" is not empty
    Sub_Mount "${RDE_APP_IMAGE}" "${RDE_APP_MOUNT_POINT}"
    
    # Process all the *.desktop files, so that they will point to
    # the proper app's mount points. Also, they will source the env's setup
    # script before launching the apps.
    Sub_ProcessDesktop
    
    # The following section between the double quotation marks will be appended
    # to the env's setup script. It will be automatically sourced before starting
    # the env's terminal or apps.
    Sub_AppendToSetEnvFile "
## App: Template
export TEMPLATE_HOME=${RDE_APP_MOUNT_POINT}
export PATH=${RDE_APP_MOUNT_POINT}/bin:\${PATH}
echo -e '${_COLOR_On_Purple}App: Template${_COLOR_Off}'
echo -e '  - ${_COLOR_BYellow}template.sh${_COLOR_Off} : a template app.'
echo ""
"
    ;;
  deactivate)
    Sub_Unmount "${RDE_APP_MOUNT_POINT}"
    ;;
  *)
    log_msg "[WRN] I don't understand: RDE_ENV_ACTION=${RDE_ENV_ACTION}"
    ;;
esac

