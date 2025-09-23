#!/usr/bin/env sh
set -e

# Ensure ownership for node user on its home and n8n config
mkdir -p /home/node/.n8n
chown -R node:node /home/node

# If a volume mounts /home/node/.n8n with wrong perms, fix it
if [ -d /home/node/.n8n ]; then
  chmod 700 /home/node/.n8n || true
fi

# System Chrome is already installed, no need to install Puppeteer Chrome

# Drop to node user and exec
exec su-exec node:node "$@"


