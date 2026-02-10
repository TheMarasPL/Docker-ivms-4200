# iVMS-4200 in Docker (Linux host)

This repository provides a Docker image that runs **Hikvision iVMS-4200 (Windows build)** inside Wine, exposed via **RDP**.

## What this image does

- Installs Wine (64-bit + 32-bit support) and common runtime dependencies.
- Runs XRDP so you can connect with any RDP client.
- Starts a session that launches only iVMS-4200 (instead of a full desktop workflow).
- Supports auto-install from an installer you mount into the container.

> Note: Hikvision does not provide an official Linux container package for iVMS-4200. Some hardware-accelerated/codec-specific features may still depend on your host, camera stream format, and Wine compatibility.

## Prerequisites

1. Put the official iVMS installer (`.exe` or `.msi`) into `./installer/`.
2. Build and run with Docker/Compose on your Linux host.

## Build and run

```bash
mkdir -p installer
# copy installer file into ./installer

docker compose build
docker compose up -d
```

## Connect

- RDP endpoint: `localhost:3389`
- Username: `ivms`
- Password: `ivms`

On first start, the container tries a best-effort silent install. If silent flags are not supported by your installer variant, connect over RDP and complete the installer manually.

## Volumes

- `./installer:/opt/ivms/installer` – place iVMS installer here.
- `ivms_wine:/home/ivms/.wine` – persistent Wine prefix (keeps installed app/settings).
- `ivms_logs:/opt/ivms/logs` – logs from supervisor/XRDP/installation.

## Useful commands

```bash
# Follow logs
docker compose logs -f

# Re-run installer manually inside running container
docker compose exec ivms-4200 su - ivms -c '/usr/local/bin/install-ivms.sh'

# Check installation log
docker compose exec ivms-4200 tail -n 200 /opt/ivms/logs/install.log
```

## Security notes

- Change default credentials before exposing beyond localhost.
- Prefer VPN or SSH tunnel for remote access.
- iVMS/Wine runs with user-level permissions (`ivms`), not root.

## CI/CD

A GitHub Actions workflow is included at `.github/workflows/docker-build-main.yml` and runs on every push to `main` (and manually via `workflow_dispatch`) to build the Docker image.
