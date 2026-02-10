FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    WINEPREFIX=/home/ivms/.wine \
    WINEARCH=win64 \
    DISPLAY=:10 \
    XRDP_USER=ivms

# Base OS deps + desktop + RDP + Wine prereqs
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    supervisor \
    xrdp \
    xorgxrdp \
    xfce4 \
    dbus-x11 \
    xauth \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    openbox \
    xterm \
    cabextract \
    unzip \
    p7zip-full \
    procps \
    fonts-wqy-zenhei \
    fonts-dejavu \
    libasound2-plugins \
    libpulse0 \
    libnss-mdns \
    mesa-utils \
    wget \
 && rm -rf /var/lib/apt/lists/*

# Install Wine from WineHQ (newer than distro package)
RUN mkdir -pm755 /etc/apt/keyrings \
 && curl -fsSL https://dl.winehq.org/wine-builds/winehq.key -o /etc/apt/keyrings/winehq-archive.key \
 && curl -fsSL https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources -o /etc/apt/sources.list.d/winehq-jammy.sources \
 && apt-get update \
 && apt-get install -y --install-recommends winehq-stable winetricks \
 && rm -rf /var/lib/apt/lists/*

# Runtime user
RUN useradd -m -s /bin/bash ${XRDP_USER} \
 && echo "${XRDP_USER}:${XRDP_USER}" | chpasswd \
 && usermod -aG audio,video ${XRDP_USER}

# Pre-create WINE prefix to avoid first-run race during RDP login
USER ${XRDP_USER}
RUN wineboot --init && wineserver -w

USER root

# XRDP starts this for each session; we launch only iVMS app (no full desktop shell)
COPY scripts/xsession-ivms.sh /usr/local/bin/xsession-ivms.sh
RUN chmod +x /usr/local/bin/xsession-ivms.sh \
 && echo '/usr/local/bin/xsession-ivms.sh' > /home/${XRDP_USER}/.xsession \
 && chown ${XRDP_USER}:${XRDP_USER} /home/${XRDP_USER}/.xsession

# Utility scripts
COPY scripts/install-ivms.sh /usr/local/bin/install-ivms.sh
COPY scripts/start-ivms.sh /usr/local/bin/start-ivms.sh
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/start-browser-desktop.sh /usr/local/bin/start-browser-desktop.sh
RUN chmod +x /usr/local/bin/install-ivms.sh /usr/local/bin/start-ivms.sh /usr/local/bin/start-browser-desktop.sh /entrypoint.sh

# Supervisor + XRDP config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN sed -i 's/^port=.*/port=3389/' /etc/xrdp/xrdp.ini \
 && sed -i 's/^max_bpp=.*/max_bpp=24/' /etc/xrdp/xrdp.ini \
 && echo 'allowed_users=anybody' >> /etc/X11/Xwrapper.config

# Location to mount iVMS installer executable
RUN mkdir -p /opt/ivms/installer /opt/ivms/logs \
 && chown -R ${XRDP_USER}:${XRDP_USER} /opt/ivms

EXPOSE 3389 6080
VOLUME ["/opt/ivms/installer", "/home/ivms/.wine", "/opt/ivms/logs"]

ENTRYPOINT ["/entrypoint.sh"]
