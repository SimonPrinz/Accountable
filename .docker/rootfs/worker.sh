#!/usr/bin/env bash

if [[ -z "${WORKER}" ]]; then
    echo "No worker given!"
    /run/s6/basedir/bin/halt
    exit 1
fi

console ${WORKER}
