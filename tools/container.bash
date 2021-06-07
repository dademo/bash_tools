#!/bin/bash


export CONTAINER_TOOL="$(command -v docker)"

if [ -z "${CONTAINER_TOOL}" ]; then
    export CONTAINER_TOOL="$(command -v podman)"
fi

if [ -z "${CONTAINER_TOOL}" ]; then
    echo "Unable to locate docker or podman tool, cannot continue"
    exit 1
fi

## BEGIN CONTAINER TOOLS ##
function container_search() {
    "${CONTAINER_TOOL}" container list --format '{{.Names}}' | grep -e "${CONTAINER_NAME}" || true
}

function container_clean() {

    if [ -n "$(container_search)" ]; then
        "${CONTAINER_TOOL}" rm "${CONTAINER_NAME}" > /dev/null
    fi
}
