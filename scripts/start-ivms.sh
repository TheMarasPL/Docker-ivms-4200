#!/usr/bin/env bash
set -euo pipefail

INSTALLER_DIR="/opt/ivms/installer"

# Common install locations for iVMS-4200 binaries in Wine prefix
candidates=(
  "$WINEPREFIX/drive_c/Program Files (x86)/iVMS-4200/iVMS-4200 Client/iVMS-4200.exe"
  "$WINEPREFIX/drive_c/Program Files (x86)/iVMS-4200/iVMS-4200.exe"
  "$WINEPREFIX/drive_c/Program Files/iVMS-4200/iVMS-4200 Client/iVMS-4200.exe"
  "$WINEPREFIX/drive_c/Program Files/iVMS-4200/iVMS-4200.exe"
)

find_ivms_binary() {
  local c
  for c in "${candidates[@]}"; do
    if [ -f "$c" ]; then
      printf '%s\n' "$c"
      return 0
    fi
  done

  return 1
}

if IVMS_BIN="$(find_ivms_binary)"; then
  exec wine "$IVMS_BIN"
fi

shopt -s nullglob
installers=("$INSTALLER_DIR"/*.exe "$INSTALLER_DIR"/*.msi)

if [ ${#installers[@]} -eq 0 ]; then
  echo "iVMS executable not found and no installer is available in $INSTALLER_DIR."
  echo "Place the installer in the mounted installer directory and log in again."
  echo "Looked in:"
  printf ' - %s\n' "${candidates[@]}"
  # Keep session alive so user can inspect/fix from desktop.
  exec xterm -fa Monospace -fs 11 -e "bash -lc 'echo iVMS not installed and installer missing; read -n 1 -s -r -p \"Press any key to exit...\"'"
fi

installer="${installers[0]}"
echo "iVMS is not installed yet. Starting interactive installer: $installer"

if [[ "$installer" == *.msi ]]; then
  exec msiexec /i "$installer"
fi

exec wine "$installer"
