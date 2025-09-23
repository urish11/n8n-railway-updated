FROM n8nio/n8n:latest

# We’ll install only the minimal shared-libs Chrome needs.
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    libasound2 \
    libatk1.0-0 \
    libcups2 \
    libx11-6 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxfixes3 \
    libxext6 \
    libxkbcommon0 \
    libxshmfence1 \
    libgbm1 \
    libgtk-3-0 \
    libnss3 \
    libnspr4 \
    libdrm2 \
    libglib2.0-0 \
    dbus \
 && rm -rf /var/lib/apt/lists/*

# Puppeteer runtime envs + a stable place for the Chrome binary
ENV PUPPETEER_CACHE_DIR=/home/node/.cache/puppeteer \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_ARGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --single-process"

# Create cache dir and prefetch Chrome so it’s baked into the image
RUN mkdir -p /home/node/.cache/puppeteer && chown -R node:node /home/node

USER node
# Download Chrome into Puppeteer’s cache and make a stable symlink
RUN npx puppeteer browsers install chrome && \
    CHROME_BIN="$(find /home/node/.cache/puppeteer -type f -path '*/chrome-linux64/chrome' | sort | tail -n1)" && \
    echo "Cached Chrome at: ${CHROME_BIN}" && \
    ln -sf "${CHROME_BIN}" /home/node/.cache/puppeteer/chrome-bin

# Point Puppeteer (and your n8n node) at a stable path
ENV PUPPETEER_EXECUTABLE_PATH=/home/node/.cache/puppeteer/chrome-bin

# Base image already sets up entrypoint/cmd for n8n; keep running as node
