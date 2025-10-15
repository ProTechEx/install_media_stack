# 🧩 Media Stack Installer

A simple **one-command installer** for a complete self-hosted media automation environment in Docker.

It deploys:

- **Portainer CE** — Docker management UI  
- **Radarr** — Movie automation  
- **Sonarr** — TV automation  
- **SABnzbd** — Usenet downloader  
- **Deluge** — Torrent client  (Default password: deluge)
- **Jackett** — Indexer bridge  
- **FlareSolverr** — Cloudflare solver (used by indexers)  
- **Requestrr** — Media request bot  
- **Watchtower** — Auto-update containers  

The installer **auto-detects Ubuntu/Debian** and installs Docker & the Compose plugin via the **official Docker repository**, then provisions a consistent folder structure and starts the full stack.

---

## 📚 Table of Contents

- [🚀 Installation](#-installation)
- [🧰 The Script Will](#-the-script-will)
- [📁 Folder Structure](#-folder-structure)
- [🌐 Default Web Interfaces](#-default-web-interfaces)
- [🧠 Requirements](#-requirements)
- [🔄 Updating Containers](#-updating-containers)
- [💾 Uninstallation](#-uninstallation)
- [👨‍💻 Maintainer](#-maintainer)
- [📝 License](#-license)

---

## 🚀 Installation

Run this command as **root** or with `sudo`:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ProTechEx/install_media_stack/refs/heads/main/install_media_stack.sh)
```

> The script prints progress and finishes with a summary of URLs using your **public server IP**.

---

## 🧰 The Script Will

- Detect your OS (**Ubuntu** or **Debian**).  
- Install **Docker Engine** and **Docker Compose plugin** using the **official Docker APT repository**.  
- Create a clean directory structure under `~/media-stack`.  
- Generate a production-ready `docker-compose.yml`.  
- Pull and start all containers.  
- Print a summary table with **direct URLs** built from your public IP.  

---

## 📁 Folder Structure

```arduino
~/media-stack/
├── docker-compose.yml
├── config/
│   ├── radarr/
│   ├── sonarr/
│   ├── sabnzbd/
│   ├── deluge/
│   ├── jackett/
│   └── requesterr/
├── downloads/
├── incomplete/
├── media/
│   ├── movies/
│   └── tv/
└── portainer_data/
```

- `config/*` — persistent app configs  
- `downloads` / `incomplete` — shared by downloaders and managers  
- `media/movies` & `media/tv` — Radarr/Sonarr library targets  

---

## 🌐 Default Web Interfaces

| Service      | Port | URL (replace with your server IP) |
|---------------|------|----------------------------------|
| Portainer     | 9000 | [http://your-server-ip:9000](http://your-server-ip:9000) |
| SABnzbd       | 8080 | [http://your-server-ip:8080](http://your-server-ip:8080) |
| Deluge        | 8112 | [http://your-server-ip:8112](http://your-server-ip:8112) |
| Jackett       | 9117 | [http://your-server-ip:9117](http://your-server-ip:9117) |
| FlareSolverr  | 8191 | [http://your-server-ip:8191](http://your-server-ip:8191) |
| Radarr        | 7878 | [http://your-server-ip:7878](http://your-server-ip:7878) |
| Sonarr        | 8989 | [http://your-server-ip:8989](http://your-server-ip:8989) |
| Requestrr     | 4545 | [http://your-server-ip:4545](http://your-server-ip:4545) |

> The installer’s final summary shows these with your **actual public IP**.

---

## 🧠 Requirements

- **OS:** Debian 11+ or Ubuntu 22.04+  
- **Privileges:** root or sudo  
- **Hardware:** ≥ 2 GB RAM recommended  
- **Network:** stable internet connection  
- **Firewall:** open ports `22, 9000, 8080, 8112, 9117, 8191, 7878, 8989, 4545`

---

## 🔄 Updating Containers

**Automatic:** Watchtower updates containers on schedule.  
**Manual update:**

```bash
cd ~/media-stack
docker compose pull && docker compose up -d
```

---

## 💾 Uninstallation

```bash
cd ~/media-stack
docker compose down -v
rm -rf ~/media-stack
cd ..
```

> This removes containers, volumes, and all persisted data under `~/media-stack`.

---

## 👨‍💻 Maintainer

**ProTechEx**  
GitHub: [https://github.com/ProTechEx](https://github.com/ProTechEx)

---

## 📝 License

Released under the **MIT License**.  
See the `LICENSE` file for details.
