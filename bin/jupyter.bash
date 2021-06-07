#!/bin/bash

set -e

## Container tools
source "$(dirname "$0")/../tools/container.bash"
source "$(dirname "$0")/../tools/web.bash"

ACTION="run"
CONTAINER_DETACH="--detach"
CONTAINER_RM="--rm"
CONTAINER_NAME="jupyter-notebook"
CONTAINER_EXPOSED_PORT="8888"
IMAGE_NAME="jupyter/scipy-notebook"
IMAGE_PULL="always"
VOLUME_NAME="jupyter-notebook-volume"
DEFAULT_BROWSER="firefox"

## OTHER VALUES ##
CONTAINER_LOGS_FOLLOW=""

function help() {
    cat << EOF
Usage:
    jupyter.bash [action] [arguments...]

Actions:
    run,start           Run the container
    stop                Stop the container
    kill                Kill the container
    logs                Get the container logs
    stats               Get the container statistics
    inspect             Inspect the container configuration
    open                Open Jupyter in the local web browser

Options:
    --attach            Disable the detached mode
    --no-rm             Disable container removing when stopping container
    --no-open           Do not open application after it started
    --container-name    Set the running container name (defaults to "${CONTAINER_NAME}")
    --image-name        Set the image to run (defaults to "${IMAGE_NAME}")
    --image-pull        Whether to pull the image (any of "always"|"missing"|"never", defaults to "${IMAGE_PULL}")
    --volume-name       Set the persistant volume name (defaults to "${VOLUME_NAME}")
    --follow, -f        Follow the logs (only used with the "logs" option)
    --pubish, -p        Set the exposed port (run and open commands only)
    --help              Print this help and quit
EOF
}

## Actions
function action_stop() {

    if [ -z "$(container_search)" ]; then
        echo "Container \"${CONTAINER_NAME}\" not found"
        return 1
    fi

    "${CONTAINER_TOOL}" stop "${CONTAINER_NAME}" > /dev/null

    container_clean

    if [ $? -ne 0 ]; then
        echo "An error occured when removing container \"${CONTAINER_NAME}\""
        return 1
    fi

    echo "Container \"${CONTAINER_NAME}\" stopped"
    return 0
}

function action_kill() {

    if [ -z "$(container_search)" ]; then
        echo "Container \"${CONTAINER_NAME}\" not found"
        return 1
    fi

    "${CONTAINER_TOOL}" kill "${CONTAINER_NAME}" > /dev/null

    container_clean
    if [ $? -ne 0 ]; then
        echo "An error occured when removing container \"${CONTAINER_NAME}\""
        return 1
    fi

    echo "Container \"${CONTAINER_NAME}\" killed"
    return 0
}

function action_run() {

    "${CONTAINER_TOOL}" volume create jupyter-notebook-volume || true

    "${CONTAINER_TOOL}" run \
        "${CONTAINER_DETACH}" \
        "${CONTAINER_RM}" \
        --pull "${IMAGE_PULL}" \
        --publish "${CONTAINER_EXPOSED_PORT}:8888" \
        --name "${CONTAINER_NAME}" \
        -v "${VOLUME_NAME}:/home/jovyan/work" \
        "${IMAGE_NAME}"

    if [ -z "${NO_OPEN}" ]; then

        echo "Waiting for the application to start..."
        sleep 2
        action_open
    fi
    return 0
}

function action_logs() {

    if [ -z "$(container_search)" ]; then
        echo "Container \"${CONTAINER_NAME}\" not found"
        return 1
    fi

    "${CONTAINER_TOOL}" logs ${CONTAINER_LOGS_FOLLOW} "${CONTAINER_NAME}"
    return 0
}

function action_stats() {

    if [ -z "$(container_search)" ]; then
        echo "Container \"${CONTAINER_NAME}\" not found"
        return 1
    fi

    "${CONTAINER_TOOL}" stats "${CONTAINER_NAME}"
    return 0
}

function action_inspect() {

    if [ -z "$(container_search)" ]; then
        echo "Container \"${CONTAINER_NAME}\" not found"
        return 1
    fi

    "${CONTAINER_TOOL}" inspect "${CONTAINER_NAME}"
    return 0
}

function action_open() {

    if [ -z "$(container_search)" ]; then
        echo "Container \"${CONTAINER_NAME}\" not found"
        return 1
    fi

    URL="$("${CONTAINER_TOOL}" logs "${CONTAINER_NAME}" 2>&1 | grep -e 'http://127.0.0.1' | head -n 1 |  sed -E "s/.+(http:\/\/.+)$/\1/g; s/8888/${CONTAINER_EXPOSED_PORT}/g")"

    if [ -z "${URL}" ]; then
        echo "Unable to get URL from logs"
        return 1
    fi

    open_in_default_browser "${URL}"
    return 0
}


case "$1" in
    run|start)
        ACTION="run"
        shift
        ;;
    stop)
        ACTION="stop"
        shift
        ;;
    logs)
        ACTION="logs"
        shift
        ;;
    kill)
        ACTION="kill"
        shift
        ;;
    stats)
        ACTION="stats"
        shift
        ;;
    inspect)
        ACTION="inspect"
        shift
        ;;
    open)
        ACTION="open"
        shift
        ;;
esac

while [ $# -gt 0 ]; do
    case "$1" in
        --attach)
            CONTAINER_DETACH=""
            shift
            ;;
        --no-rm)
            CONTAINER_RM=""
            shift
            ;;
        --no-open)
            NO_OPEN="y"
            shift
            ;;
        --container-name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        --image-name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        --image-pull)
            IMAGE_PULL="$2"
            shift 2
            ;;
        --volume-name)
            VOLUME_NAME="$2"
            shift 2
            ;;
        --follow|-f)
            CONTAINER_LOGS_FOLLOW="--follow"
            shift
            ;;
        --port|-p)
            CONTAINER_EXPOSED_PORT="$2"
            shift 2
            ;;
        --help)
            help
            exit 0
            ;;
        *)
            echo "Unknown argument \"$1\""
            help
            exit 1
            ;;
    esac
done

case "${ACTION}" in
    run)
        action_run
        ;;
    stop)
        action_stop
        ;;
    kill)
        action_kill
        ;;
    logs)
        action_logs
        ;;
    stats)
        action_stats
        ;;
    inspect)
        action_inspect
        ;;
    open)
        action_open
        ;;
    *)
        echo "Unknown action \"${ACTION}\""
        exit 1
esac

exit $?
