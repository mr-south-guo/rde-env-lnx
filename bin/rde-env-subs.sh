#!/bin/echo *** This script should only be sourced, e.g.: . 

##  Bash Color Constants
##  Ref: https://wiki.archlinux.org/index.php/Color_Bash_Prompt
Sub_SetColor() {
  # Reset
  export _COLOR_Off="\033[0m"       # Text Reset

  # Regular Colors
  export _COLOR_Black="\033[0;30m"        # Black
  export _COLOR_Red="\033[0;31m"          # Red
  export _COLOR_Green="\033[0;32m"        # Green
  export _COLOR_Yellow="\033[0;33m"       # Yellow
  export _COLOR_Blue="\033[0;34m"         # Blue
  export _COLOR_Purple="\033[0;35m"       # Purple
  export _COLOR_Cyan="\033[0;36m"         # Cyan
  export _COLOR_White="\033[0;37m"        # White

  # Bold
  export _COLOR_BBlack="\033[1;30m"       # Black
  export _COLOR_BRed="\033[1;31m"         # Red
  export _COLOR_BGreen="\033[1;32m"       # Green
  export _COLOR_BYellow="\033[1;33m"      # Yellow
  export _COLOR_BBlue="\033[1;34m"        # Blue
  export _COLOR_BPurple="\033[1;35m"      # Purple
  export _COLOR_BCyan="\033[1;36m"        # Cyan
  export _COLOR_BWhite="\033[1;37m"       # White

  # Underline
  export _COLOR_UBlack="\033[4;30m"       # Black
  export _COLOR_URed="\033[4;31m"         # Red
  export _COLOR_UGreen="\033[4;32m"       # Green
  export _COLOR_UYellow="\033[4;33m"      # Yellow
  export _COLOR_UBlue="\033[4;34m"        # Blue
  export _COLOR_UPurple="\033[4;35m"      # Purple
  export _COLOR_UCyan="\033[4;36m"        # Cyan
  export _COLOR_UWhite="\033[4;37m"       # White

  # Background
  export _COLOR_On_Black="\033[40m"       # Black
  export _COLOR_On_Red="\033[41m"         # Red
  export _COLOR_On_Green="\033[42m"       # Green
  export _COLOR_On_Yellow="\033[43m"      # Yellow
  export _COLOR_On_Blue="\033[44m"        # Blue
  export _COLOR_On_Purple="\033[45m"      # Purple
  export _COLOR_On_Cyan="\033[46m"        # Cyan
  export _COLOR_On_White="\033[47m"       # White

  # High Intensity
  export _COLOR_IBlack="\033[0;90m"       # Black
  export _COLOR_IRed="\033[0;91m"         # Red
  export _COLOR_IGreen="\033[0;92m"       # Green
  export _COLOR_IYellow="\033[0;93m"      # Yellow
  export _COLOR_IBlue="\033[0;94m"        # Blue
  export _COLOR_IPurple="\033[0;95m"      # Purple
  export _COLOR_ICyan="\033[0;96m"        # Cyan
  export _COLOR_IWhite="\033[0;97m"       # White

  # Bold High Intensity
  export _COLOR_BIBlack="\033[1;90m"      # Black
  export _COLOR_BIRed="\033[1;91m"        # Red
  export _COLOR_BIGreen="\033[1;92m"      # Green
  export _COLOR_BIYellow="\033[1;93m"     # Yellow
  export _COLOR_BIBlue="\033[1;94m"       # Blue
  export _COLOR_BIPurple="\033[1;95m"     # Purple
  export _COLOR_BICyan="\033[1;96m"       # Cyan
  export _COLOR_BIWhite="\033[1;97m"      # White

  # High Intensity backgrounds
  export _COLOR_On_IBlack="\033[0;100m"   # Black
  export _COLOR_On_IRed="\033[0;101m"     # Red
  export _COLOR_On_IGreen="\033[0;102m"   # Green
  export _COLOR_On_IYellow="\033[0;103m"  # Yellow
  export _COLOR_On_IBlue="\033[0;104m"    # Blue
  export _COLOR_On_IPurple="\033[10;95m"  # Purple
  export _COLOR_On_ICyan="\033[0;106m"    # Cyan
  export _COLOR_On_IWhite="\033[0;107m"   # White
}

Sub_SetXTermTitle() {
  echo -ne "\033]0;${1}\007"
}

Sub_EchoHeading1() {
  echo -e "${_COLOR_On_Blue}$1${_COLOR_IGreen} $2${_COLOR_Off}"
}

Sub_EchoHeading2() {
  echo -e "${_COLOR_On_Blue}$1${_COLOR_IRed} $2${_COLOR_Off}"
}

Sub_EchoHeading3() {
  echo -e "${_COLOR_On_Blue}$1${_COLOR_Yellow} $2${_COLOR_Off}"
}

log_msg() {
  case "$1" in
    \[ERR\]*) echo -e "${_COLOR_IRed}$@${_COLOR_Off}"
    ;;
    \[WRN\]*) echo -e "${_COLOR_IYellow}$@${_COLOR_Off}"
    ;;
    \[INF\]*) echo -e "${_COLOR_IGreen}$@${_COLOR_Off}"
    ;;
    *) echo -e "${_COLOR_Off}$@"
    ;;
  esac  
}

Sub_PrepareEmptyDir() {
  local TARGET_DIR=$1
  local ERRLVL_ERR=1
  local ERRLVL_OK=0

  # Check if the directory exists.
  if [ -e "${TARGET_DIR}" ]; then
    # Yes. Then check if the directory is empty.
    if find ${TARGET_DIR}/ -maxdepth 0 -empty | read v; then
      log_msg "[WRN] ${TARGET_DIR} exists but empty."
    else
      log_msg "[WRN] ${TARGET_DIR} exists and is NOT empty."
      return ${ERRLVL_ERR}
    fi
  fi

  # Create the directory (and parent directories if needed).
  sudo mkdir -p "${TARGET_DIR}"
  sudo chown ${USER}:${USER} "${TARGET_DIR}"
  sudo chmod 0755 "${TARGET_DIR}"
  if [ ! -e "${TARGET_DIR}" ]; then
		log_msg "[ERR] ${TARGET_DIR} cannot be created."
		return ${ERRLVL_ERR}
	fi

  return ${ERRLVL_OK}
}

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
    return $?
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
        *) echo "Unknow file extension: ${FILE_NAME}"
        return 1
        ;;
      esac
  fi
  return $?
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

Sub_SetColor
