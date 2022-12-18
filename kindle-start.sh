#!/usr/bin/env bash
set -euo pipefail

CNT_NAME=cnt-wine
if  !(lxc list -c ns | grep $CNT_NAME | grep RUNNING > /dev/null 2>&1) ; then
    lxc start $CNT_NAME
    if  !(lxc list -c ns | grep $CNT_NAME | grep RUNNING > /dev/null 2>&1) ; then
        echo "ERR: Contaner $CNT_NAME is not RUNNING"
        exit 1
    fi
fi
echo "container <${CNT_NAME}> is running."

ssh $CNT_NAME "DISPLAY=:0 bash ./kindle.sh"
