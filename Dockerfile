FROM alpine:latest
LABEL maintainer="dantavares"
ARG TARGETARCH

# environment settings
ENV XDG_DATA_HOME="/config" \
    XDG_CONFIG_HOME="/config"

# Volume config: home directory for execution user, contains ServerConfig.json and configuration dirs (generated at first start if needed)
VOLUME /config
# Volume downloads
VOLUME /downloads

# Set execution user (PUID/PGID)
ENV AUTO_UPDATE="true"\
    PUID="1000"\
    PGID="1000"
# Set xterm for nano
ENV TERM=xterm

# Update packages and install software
RUN \
  echo "**** install packages ****" && \
  apk update && apk --no-cache add dumb-init shadow su-exec\
  icu-data-full curl jq libc-utils icu-libs
	
# Download and manually install Jackett
RUN mkdir -p /opt/jackett \
	&& mkdir -p /etc/jackett \
 	&& export JACKETT_VERSION=$(curl -k -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" | tac | awk '/tag_name/{print $4;exit}' FS='[""]') \
	&& echo $JACKETT_VERSION > /etc/jackett/jackett_version \
	&& if [ "$TARGETARCH" = "arm" ]; then export ARCH="ARM32"; else export ARCH="AMDx64"; fi \
	&& echo "Platform: " $ARCH \
	&& curl -k -o /tmp/jackett.tar.gz -L https://github.com/Jackett/Jackett/releases/download/$JACKETT_VERSION/Jackett.Binaries.LinuxMusl$ARCH.tar.gz \
	&& tar xf /tmp/jackett.tar.gz -C /opt/jackett --strip-components=1 \
 	&& rm /tmp/jackett.tar.gz

# Create and set user & group for impersonation
RUN groupmod -g $PGID users \
    && useradd -u $PUID -U -d /config -s /bin/false jackett \
    && usermod -G users jackett
	
# Copy scripts
COPY jackett/ /etc/jackett/

# Make scripts executable
RUN chmod +x /etc/jackett/*.sh

# Expose port
EXPOSE 9117

# Launch Jackett at container start
ENTRYPOINT ["/usr/bin/dumb-init", "/etc/jackett/start.sh"]
