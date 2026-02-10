#!/usr/bin/env bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:10}"
export WINEPREFIX="${WINEPREFIX:-/home/ivms/.wine}"
export LANG="${LANG:-en_US.UTF-8}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-ivms}"

mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Give Xvfb a short moment to initialize before launching the window manager/app.
sleep 2

openbox >/opt/ivms/logs/openbox.log 2>&1 &

# Run iVMS in this persistent desktop session.
exec /usr/local/bin/start-ivms.sh >>/opt/ivms/logs/ivms-desktop.log 2>&1
