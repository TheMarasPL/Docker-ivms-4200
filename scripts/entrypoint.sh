#!/usr/bin/env bash
set -euo pipefail

XRDP_USER="${XRDP_USER:-ivms}"

# Ensure runtime dirs
mkdir -p /var/run/dbus /var/run/xrdp /opt/ivms/logs
chown -R "${XRDP_USER}:${XRDP_USER}" /opt/ivms /home/${XRDP_USER}

# Auto-run installer only when explicitly enabled
if [ "${AUTO_INSTALL_IVMS:-0}" = "1" ]; then
  su - "${XRDP_USER}" -c "/usr/local/bin/install-ivms.sh" || true
fi

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
