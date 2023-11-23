#!/usr/bin/env bash


GUEST_NAME="$1"
OPERATION="$2"


if [ "$GUEST_NAME" == "Gaming" ]; then
    if [ "$OPERATION" == "prepare" ]; then
        systemctl stop nvidia-persistenced
    fi

    if [ "$OPERATION" == "stopped" ]; then
        systemctl start nvidia-persistenced
    fi
fi
