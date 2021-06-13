#!/bin/bash


export CONTAINER_TOOL="$(command -v docker)"

if [ -z "${CONTAINER_TOOL}" ]; then
    export CONTAINER_TOOL="$(command -v podman)"
fi

if [ -z "${CONTAINER_TOOL}" ]; then
    echo "Unable to locate docker or podman tool, cannot continue" 1>&2
    exit 1
fi

## BEGIN CONTAINER TOOLS ##
function container_search() {

    _CONTAINER_NAME="${1:-${CONTAINER_NAME}}"
    if [ -z "${_CONTAINER_NAME}" ]; then
        echo 'Container name not given. You MUST set this value in the variable ${CONTAINER_NAME} or as first parameter of this function' 1>&2
        return 1
    fi

    "${CONTAINER_TOOL}" container list --format '{{.Names}}' | grep -e "${_CONTAINER_NAME}" || true
}

function container_volume_search() {

    _CONTAINER_VOLUME_NAME="${1:-${CONTAINER_VOLUME_NAME}}"
    if [ -z "${_CONTAINER_VOLUME_NAME}" ]; then
        echo 'Container volume name not given. You MUST set this value in the variable ${CONTAINER_VOLUME_NAME} or as first parameter of this function' 1>&2
        return 1
    fi

    "${CONTAINER_TOOL}" volume list --format '{{.Name}}' | grep -e "${_CONTAINER_VOLUME_NAME}" || true
}

function container_stop() {

    _CONTAINER_NAME="${1:-${CONTAINER_NAME}}"
    if [ -z "${_CONTAINER_NAME}" ]; then
        echo 'Container name not given. You MUST set this value in the variable ${CONTAINER_NAME} or as first parameter of this function' 1>&2
        return 1
    fi

    if [ -n "$(container_search "${_CONTAINER_NAME}")" ]; then
        "${CONTAINER_TOOL}" stop "${_CONTAINER_NAME}" > /dev/null
    fi
}

function container_clean() {

    _CONTAINER_NAME="${1:-${CONTAINER_NAME}}"
    if [ -z "${_CONTAINER_NAME}" ]; then
        echo 'Container name not given. You MUST set this value in the variable ${CONTAINER_NAME} or as first parameter of this function' 1>&2
        return 1
    fi

    if [ -n "$(container_search "${_CONTAINER_NAME}")" ]; then
        "${CONTAINER_TOOL}" rm "${_CONTAINER_NAME}" > /dev/null
    fi
}

function container_volume_create() {

    _CONTAINER_VOLUME_NAME="${1:-${CONTAINER_VOLUME_NAME}}"
    if [ -z "${_CONTAINER_VOLUME_NAME}" ]; then
        echo 'Container volume name not given. You MUST set this value in the variable ${CONTAINER_VOLUME_NAME} or as first parameter of this function' 1>&2
        return 1
    fi

    if [ -z "$(container_search "${_CONTAINER_NAME}")" ]; then
        "${CONTAINER_TOOL}" volume create "${_CONTAINER_VOLUME_NAME}" > /dev/null
    fi
}

function container_volume_remove() {

    _CONTAINER_VOLUME_NAME="${1:-${CONTAINER_VOLUME_NAME}}"
    if [ -z "${_CONTAINER_VOLUME_NAME}" ]; then
        echo 'Container volume name not given. You MUST set this value in the variable ${CONTAINER_VOLUME_NAME} or as first parameter of this function' 1>&2
        return 1
    fi

    if [ -n "$(container_search "${_CONTAINER_NAME}")" ]; then
        "${CONTAINER_TOOL}" volume rm "${_CONTAINER_VOLUME_NAME}" > /dev/null
    fi
}

