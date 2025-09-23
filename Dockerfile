FROM n8nio/n8n:latest

# Install Chrome and dependencies for Alpine
USER root
RUN apk add --no-cache \
    chromium \
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

# Install puppeteer so it's available in the container.
RUN npm init -y &&  \
    npm i puppeteer \
    # Add user so we don't need --no-sandbox.
    # same layer as npm install to keep re-chowned files from using up several hundred MBs more space
    && groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /node_modules \
    && chown -R pptruser:pptruser /package.json \
    && chown -R pptruser:pptruser /package-lock.json

# Ensure n8n config dir exists with correct permissions
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

# Use system Chrome (chromium on Alpine)
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_ARGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --single-process"

# Switch back to root for entrypoint setup
USER root

# Copy entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Use entrypoint that fixes permissions and runs n8n as node
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
