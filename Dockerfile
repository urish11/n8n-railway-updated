FROM docker.n8n.io/n8nio/n8n:latest

USER root

# --- Install Chromium and required deps on Alpine ---
RUN apk add --no-cache \
    chromium \
    nss \
    glib \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    ttf-liberation \
    font-noto-emoji \
    udev \
    dumb-init \
    # common headless/runtime libs
    libx11 \
    libxcomposite \
    libxdamage \
    libxext \
    libxi \
    libxrandr \
    libxfixes \
    libxcb \
    libgcc \
    libstdc++ \
    alsa-lib \
    gtk+3.0 \
    pango

# Some Alpine variants expose chromium at /usr/bin/chromium; add a browser alias
RUN if [ -x /usr/bin/chromium ]; then ln -sf /usr/bin/chromium /usr/bin/chromium-browser; fi

# Tell Puppeteer to use the system Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
# Helpful default flags for containers like Railway
ENV PUPPETEER_ARGS="--no-sandbox --disable-dev-shm-usage --headless=new"

# Install the custom node once into a stable path
RUN mkdir -p /opt/n8n-custom-nodes && \
    cd /opt/n8n-custom-nodes && \
    npm install --omit=dev n8n-nodes-puppeteer && \
    chown -R node:node /opt/n8n-custom-nodes

# Ensure n8n data dir exists and is owned by node (prevents EACCES on fresh volume)
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node

# Copy custom entrypoint
COPY docker-custom-entrypoint.sh /docker-custom-entrypoint.sh
RUN chmod +x /docker-custom-entrypoint.sh && chown node:node /docker-custom-entrypoint.sh

USER node

# Make n8n see your custom nodes dir
ENV N8N_CUSTOM_EXTENSIONS="/opt/n8n-custom-nodes"

ENTRYPOINT ["/docker-custom-entrypoint.sh"]
