FROM docker.n8n.io/n8nio/n8n:latest

USER root

# (unchanged) packages
RUN apk add --no-cache \
    chromium nss glib freetype harfbuzz ca-certificates \
    ttf-freefont ttf-liberation font-noto-emoji udev dumb-init \
    libx11 libxcomposite libxdamage libxext libxi libxrandr libxfixes \
    libxcb libgcc libstdc++ alsa-lib gtk+3.0 pango \
    su-exec  # <— add this

RUN if [ -x /usr/bin/chromium ]; then ln -sf /usr/bin/chromium /usr/bin/chromium-browser; fi

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/lib/chromium/chromium
# ENV PUPPETEER_ARGS="--no-sandbox --disable-dev-shm-usage --headless=new"

RUN mkdir -p /opt/n8n-custom-nodes && \
    cd /opt/n8n-custom-nodes && \
    npm install --omit=dev n8n-nodes-puppeteer && \
    chown -R node:node /opt/n8n-custom-nodes

# create the folder; real fix happens at runtime after mount
RUN mkdir -p /home/node/.n8n

COPY docker-custom-entrypoint.sh /docker-custom-entrypoint.sh
RUN chmod +x /docker-custom-entrypoint.sh

# IMPORTANT: stay root so entrypoint can chown the mounted volume
# USER node   <-- remove this line if you had it

ENV N8N_CUSTOM_EXTENSIONS="/opt/n8n-custom-nodes"

ENTRYPOINT ["/docker-custom-entrypoint.sh"]
