FROM n8nio/n8n:latest

# Alpine base → use apk
USER root
RUN apk add --no-cache \
    nss nspr ca-certificates \
    glib dbus-libs \
    libx11 libxcb libxext libxfixes libxrender libxi \
    libxcomposite libxdamage libxrandr \
    libxkbcommon libxshmfence \
    mesa-gbm libdrm \
    cairo pango gtk+3.0 \
    alsa-lib fontconfig ttf-freefont cups-libs \
    libc6-compat libudev-zero \
    su-exec

# Puppeteer cache dir
ENV PUPPETEER_CACHE_DIR=/home/node/.cache/puppeteer
RUN mkdir -p "$PUPPETEER_CACHE_DIR" && chown -R node:node /home/node

# Ensure n8n config dir exists with correct permissions
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
# Prefetch Chrome and create a stable symlink
RUN npx puppeteer browsers install chrome && \
    CHROME_BIN="$(find /home/node/.cache/puppeteer -type f -path '*/chrome-linux64/chrome' | sort | tail -n1)" && \
    echo "Cached Chrome at: ${CHROME_BIN}" && \
    ln -sf "${CHROME_BIN}" /home/node/.cache/puppeteer/chrome-bin

# Stable path + safe launch args
ENV PUPPETEER_EXECUTABLE_PATH=/home/node/.cache/puppeteer/chrome-bin \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_ARGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --single-process"

# Switch back to root for entrypoint setup
USER root

# Copy entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Use entrypoint that fixes permissions and runs n8n as node
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
