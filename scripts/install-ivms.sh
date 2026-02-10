#!/usr/bin/env bash
set -euo pipefail

INSTALLER_DIR="/opt/ivms/installer"
LOG_FILE="/opt/ivms/logs/install.log"

mkdir -p "$(dirname "$LOG_FILE")"

shopt -s nullglob
installers=("$INSTALLER_DIR"/*.exe "$INSTALLER_DIR"/*.msi)
if [ ${#installers[@]} -eq 0 ]; then
  echo "No iVMS installer found in $INSTALLER_DIR; skipping auto-install." | tee -a "$LOG_FILE"
  exit 0
fi

installer="${installers[0]}"

echo "Using installer: $installer" | tee -a "$LOG_FILE"

# Ensure prefix is initialized
wineboot --init >>"$LOG_FILE" 2>&1 || true
wineserver -w || true

# Best-effort silent install flags used by common NSIS/Inno installers.
# If unsupported, installation can be completed interactively through RDP.
if [[ "$installer" == *.msi ]]; then
  msiexec /i "$installer" /qn /norestart >>"$LOG_FILE" 2>&1 || true
else
  wine "$installer" /S >>"$LOG_FILE" 2>&1 || true
  wine "$installer" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART >>"$LOG_FILE" 2>&1 || true
fi

wineserver -w || true

echo "Install attempt completed. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
