# docker-jackett
A Jackett Docker running on Alpine Linux
   - Platform: armv7 or amd64
   - Automatic pull latest version
   - Auto check and update on container start
   - Not using root user on jackett exec
   
Dockerhub: [https://hub.docker.com/r/44934045/jackett](https://hub.docker.com/r/44934045/jackett)

---

Docker Compose Suggestion:

```
name: qbtnox #Example using with qbittorrent
services:
  qbtnox:
    image: qbittorrentofficial/qbittorrent-nox:latest
    container_name: qbittorrent-nox
    restart: unless-stopped
    ports:
      - "8080:8080" #WEBUI Port
      - "6881:6881" #Torrent external Port
    volumes:
      - [folder to bt config]:/config
      - [folder to download]:/downloads
    depends_on:
      - jackett
    environment:
      QBT_LEGAL_NOTICE: "confirm"
      QBT_WEBUI_PORT: "8080"
      QBT_TORRENTING_PORT: "6881"
      TZ: America/Sao_Paulo

  jackett:
    image: 44934045/jackett:armv7
    container_name: jackett
    environment:
      - TZ=America/Sao_Paulo
      - AUTO_UPDATE=true #Set "false" to disable auto update function
    volumes:
      - [folder to jackett config]:/config
      - [folder to download]:/downloads
      - /tmp:/run/jackett-temp
    #ports: #Enable only to config jackett
    #  - 9117:9117
    restart: unless-stopped
```