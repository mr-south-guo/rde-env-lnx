#!/bin/bash

MOUNT_POINT=$( readlink -f "$1" )
TMPFS_SIZE=$2

SCRIPTFULLPATH=$( readlink -f "$BASH_SOURCE" )
RDE_ENV_BINPATH=${SCRIPTFULLPATH%/*}
. "${RDE_ENV_BINPATH}/rde-env-subs.sh"

sudo mkdir -p "$MOUNT_POINT"
sudo mount -t tmpfs -o rw,size=${TMPFS_SIZE} tmpfs "$MOUNT_POINT"
