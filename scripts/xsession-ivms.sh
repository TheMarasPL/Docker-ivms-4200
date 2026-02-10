#!/usr/bin/env bash
set -euo pipefail

export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export DISPLAY="${DISPLAY:-:10}"
export LANG="${LANG:-en_US.UTF-8}"

# XRDP helper env
if [ -r /etc/profile ]; then
  # shellcheck disable=SC1091
  source /etc/profile
fi

# Start a lightweight panel-less XFCE session components needed by many apps
xfsettingsd >/dev/null 2>&1 &

# Launch iVMS and end session when app exits
/usr/local/bin/start-ivms.sh
