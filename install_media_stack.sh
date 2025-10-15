#!/bin/bash
set -e

# ---------------------------------------------------------------------------
#  Media Stack Auto Installer (Ubuntu / Debian)
# ---------------------------------------------------------------------------

# Helper function for colored output
info()    { echo -e "\033[1;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    error "Cannot detect OS. Exiting."
    exit 1
fi

info "Detected OS: $PRETTY_NAME"

# ---------------------------------------------------------------------------
#  Install Docker (Official method)
# ---------------------------------------------------------------------------
install_docker() {
    info "Installing Docker using the official repository..."

    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release

    # Remove any old Docker versions
    apt-get remove -y docker docker-engine docker.io containerd runc || true

    # Add Docker’s official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$OS/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Add repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/$OS \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    systemctl enable --now docker
    success "Docker installed successfully!"
}

# Check and install if not present
if ! command -v docker &>/dev/null; then
    if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
        install_docker
    else
        error "Unsupported OS: $OS"
        exit 1
    fi
else
    success "Docker is already installed!"
fi

# ---------------------------------------------------------------------------
#  Setup Directories
# ---------------------------------------------------------------------------
info "Preparing directories..."
mkdir -p ~/media-stack/{config/{radarr,sonarr,sabnzbd,deluge,jackett,requesterr},downloads,incomplete,media/{movies,tv},portainer_data}
cd ~/media-stack

# ---------------------------------------------------------------------------
#  Create docker-compose.yml
# ---------------------------------------------------------------------------
info "Creating docker-compose.yml..."

cat > docker-compose.yml <<'EOF'
services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    ports:
      - "9000:9000"
      - "9443:9443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./portainer_data:/data

  sabnzbd:
    image: linuxserver/sabnzbd:latest
    container_name: sabnzbd
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Istanbul
    ports:
      - "8080:8080"
      - "9090:9090"
    volumes:
      - ./config/sabnzbd:/config
      - ./downloads:/downloads
      - ./incomplete:/incomplete

  deluge:
    image: linuxserver/deluge:latest
    container_name: deluge
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Istanbul
    ports:
      - "8112:8112"
      - "6881:6881"
      - "6881:6881/udp"
    volumes:
      - ./config/deluge:/config
      - ./downloads:/downloads

  jackett:
    image: linuxserver/jackett:latest
    container_name: jackett
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Istanbul
    ports:
      - "9117:9117"
    volumes:
      - ./config/jackett:/config
      - ./downloads:/downloads

  flaresolverr:
    image: flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    restart: unless-stopped
    environment:
      - LOG_LEVEL=info
      - TZ=Europe/Istanbul
    ports:
      - "8191:8191"

  radarr:
    image: linuxserver/radarr:latest
    container_name: radarr
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Istanbul
    ports:
      - "7878:7878"
    volumes:
      - ./config/radarr:/config
      - ./downloads:/downloads
      - ./media/movies:/movies
    depends_on:
      - jackett
      - sabnzbd
      - deluge

  sonarr:
    image: linuxserver/sonarr:latest
    container_name: sonarr
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Istanbul
    ports:
      - "8989:8989"
    volumes:
      - ./config/sonarr:/config
      - ./downloads:/downloads
      - ./media/tv:/tv
    depends_on:
      - jackett
      - sabnzbd
      - deluge

  requesterr:
    image: thomst08/requestrr:latest
    container_name: requesterr
    restart: unless-stopped
    environment:
      - TZ=Europe/Istanbul
    ports:
      - "4545:4545"
    volumes:
      - ./config/requesterr:/root/config
    depends_on:
      - sonarr
      - radarr

  watchtower:
    image: containrrr/watchtower:latest
    container_name: watchtower
    restart: unless-stopped
    command: --cleanup --schedule "0 0 4 * * *"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
EOF

# ---------------------------------------------------------------------------
#  Start Containers
# ---------------------------------------------------------------------------
info "Pulling images and starting stack..."
docker compose pull
docker compose up -d
success "Containers are up!"

# ---------------------------------------------------------------------------
#  Display Summary
# ---------------------------------------------------------------------------
IP=$(curl -s https://api.ipify.org || echo "localhost")

echo ""
success "Media Stack Installed Successfully!"
echo ""
echo "🌐 Default Web Interfaces:"
printf "%-15s %-8s %s\n" "Service" "Port" "URL"
printf "%-15s %-8s %s\n" "--------" "----" "-------------------------------------------"
printf "%-15s %-8s http://%s:%s\n" "Portainer" "9000" "$IP" "9000"
printf "%-15s %-8s http://%s:%s\n" "SABnzbd" "8080" "$IP" "8080"
printf "%-15s %-8s http://%s:%s\n" "Deluge" "8112" "$IP" "8112"
printf "%-15s %-8s http://%s:%s\n" "Jackett" "9117" "$IP" "9117"
printf "%-15s %-8s http://%s:%s\n" "FlareSolverr" "8191" "$IP" "8191"
printf "%-15s %-8s http://%s:%s\n" "Radarr" "7878" "$IP" "7878"
printf "%-15s %-8s http://%s:%s\n" "Sonarr" "8989" "$IP" "8989"
printf "%-15s %-8s http://%s:%s\n" "Requesterr" "4545" "$IP" "4545"
echo ""
echo "📁 Installed in: ~/media-stack"
