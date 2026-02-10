#!/usr/bin/env bash
set -euo pipefail

# Common install locations for iVMS-4200 binaries in Wine prefix
candidates=(
  "$WINEPREFIX/drive_c/Program Files (x86)/iVMS-4200/iVMS-4200 Client/iVMS-4200.exe"
  "$WINEPREFIX/drive_c/Program Files (x86)/iVMS-4200/iVMS-4200.exe"
  "$WINEPREFIX/drive_c/Program Files/iVMS-4200/iVMS-4200 Client/iVMS-4200.exe"
  "$WINEPREFIX/drive_c/Program Files/iVMS-4200/iVMS-4200.exe"
)

IVMS_BIN=""
for c in "${candidates[@]}"; do
  if [ -f "$c" ]; then
    IVMS_BIN="$c"
    break
  fi
done

if [ -z "$IVMS_BIN" ]; then
  echo "iVMS executable not found. Complete installation via RDP first."
  echo "Looked in:"
  printf ' - %s\n' "${candidates[@]}"
  # Keep session alive so user can open installer manually
  exec xterm -fa Monospace -fs 11 -e "bash -lc 'echo iVMS not installed; read -n 1 -s -r -p \"Press any key to exit...\"'"
fi

exec wine "$IVMS_BIN"
