#!/usr/bin/env sh
set -e

# Ensure ownership for node user on its home and n8n config
mkdir -p /home/node/.n8n
chown -R node:node /home/node

# If a volume mounts /home/node/.n8n with wrong perms, fix it
if [ -d /home/node/.n8n ]; then
  chmod 700 /home/node/.n8n || true
fi

# Install Chrome at runtime if not already installed
if [ ! -f /home/node/.cache/puppeteer/chrome-bin ]; then
  echo "Installing Chrome at runtime..."
  su-exec node:node npx puppeteer browsers install chrome
  CHROME_BIN="$(find /home/node/.cache/puppeteer -type f -name 'chrome' -executable | sort | tail -n1)"
  if [ -n "$CHROME_BIN" ]; then
    echo "Found Chrome at: ${CHROME_BIN}"
    su-exec node:node ln -sf "${CHROME_BIN}" /home/node/.cache/puppeteer/chrome-bin
  else
    echo "Warning: Chrome binary not found after installation"
  fi
fi

# Drop to node user and exec
exec su-exec node:node "$@"


