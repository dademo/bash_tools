#!/bin/bash

function help() {
    cat << EOF
Usage:
    $(basename "$0") SCRIPT_NAME ...

Options:
    --list  List available scripts
    --help  Print this help and quit
EOF
}

## Actions
function action_list() {

    echo "Available scripts :"
    ls "$(dirname "$(realpath -P "$0")")" --color=no                 |
        grep -ve 'tools_root'                       |
        sed -E 's/^/    /g; s/.(ba|z){0,1}sh$//g'
}

function action_run() {

    SCRIPT_NAME="$1"
    SCRIPT_PATH="$(dirname "$(realpath -P "$0")")/$1"
    shift

    for EXTENSION in '' '.sh' '.bash' '.zsh'; do
        if [ -f "${SCRIPT_PATH}${EXTENSION}" ]; then
            bash "${SCRIPT_PATH}${EXTENSION}" "$@"
            exit $?
        fi
    done

    echo "Unable to locate a script named \"${SCRIPT_NAME}\""
    return 1
}


if [ $# -eq 0 ]; then
    help
    exit 1
fi

case "$1" in
    --help)
        help
        exit 0
        ;;
    --list)
        action_list
        exit 0
        ;;
    *)
        action_run "$@"
        exit $?
        ;;
esac
