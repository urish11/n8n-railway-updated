FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Install Chromium + runtime deps (Debian/Ubuntu)
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    chromium \
    xdg-utils \
    ca-certificates \
    fonts-liberation \
    fonts-noto-color-emoji \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
 && rm -rf /var/lib/apt/lists/*

# Some environments expect chromium-browser – provide alias if needed
RUN if [ -x /usr/bin/chromium ]; then ln -sf /usr/bin/chromium /usr/bin/chromium-browser; fi

# Tell Puppeteer to use the system Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
# Helpful defaults for containers like Railway
ENV PUPPETEER_ARGS="--no-sandbox --disable-dev-shm-usage --headless=new"

# Install the custom node once into a stable path
RUN mkdir -p /opt/n8n-custom-nodes && \
    cd /opt/n8n-custom-nodes && \
    npm install --omit=dev n8n-nodes-puppeteer && \
    chown -R node:node /opt/n8n-custom-nodes

# Ensure n8n data dir exists and is owned by node (prevents EACCES when a fresh volume is mounted)
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node

# Copy custom entrypoint
COPY docker-custom-entrypoint.sh /docker-custom-entrypoint.sh
RUN chmod +x /docker-custom-entrypoint.sh && chown node:node /docker-custom-entrypoint.sh

USER node

# Make n8n see your custom nodes dir
ENV N8N_CUSTOM_EXTENSIONS="/opt/n8n-custom-nodes"

ENTRYPOINT ["/docker-custom-entrypoint.sh"]
