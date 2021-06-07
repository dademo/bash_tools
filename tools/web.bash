#!/bin/bash

## BEGIN WEB TOOLS ##
function open_in_default_browser() {
    # $1 should be the URI to open
    xdg_browser="$(xdg-settings get default-web-browser || echo "${DEFAULT_BROWSER}")"
    gtk-launch ${xdg_browser} "$@" &>/dev/null &
}
