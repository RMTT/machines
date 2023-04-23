#!/usr/bin/env bash

GUEST_NAME="$1"
OPERATION="$2"
SUB_OPERATION="$3"

# host used cpu when guest is started
allowedCPUs="0-7,16-23"

if [ "$GUEST_NAME" == "Gaming" ]; then
    if [ "$OPERATION" == "prepare" ]; then
        systemctl stop nvidia-persistenced
        systemctl set-property --runtime -- system.slice AllowedCPUs=$allowedCPUs
	systemctl set-property --runtime -- user.slice AllowedCPUs=$allowedCPUs
	systemctl set-property --runtime -- init.slice AllowedCPUs=$allowedCPUs
    fi

    if [ "$OPERATION" == "stopped" ]; then
        systemctl start nvidia-persistenced
        systemctl set-property --runtime -- system.slice AllowedCPUs=0-31
	systemctl set-property --runtime -- user.slice AllowedCPUs=0-31
	systemctl set-property --runtime -- init.slice AllowedCPUs=0-31
    fi
fi
