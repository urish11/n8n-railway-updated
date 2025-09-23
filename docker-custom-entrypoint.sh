#!/bin/sh
set -e

print_banner() {
  echo "----------------------------------------"
  echo "n8n Puppeteer Node - Environment Details"
  echo "----------------------------------------"
  echo "Running as: $(id -u -n) (uid $(id -u))"
  echo "Node.js: $(node -v || true)"
  echo "n8n: $(n8n --version || true)"
  CHROME_VERSION=$("$PUPPETEER_EXECUTABLE_PATH" --version 2>/dev/null || echo "Chromium not found")
  echo "Chromium: $CHROME_VERSION"
  echo "Puppeteer exec path: $PUPPETEER_EXECUTABLE_PATH"
  echo "Custom nodes dir: $N8N_CUSTOM_EXTENSIONS"
  echo "----------------------------------------"
}

# Ensure mounted volume is writable by 'node'
if [ -d "/home/node/.n8n" ]; then
  chown -R node:node /home/node/.n8n || true
else
  mkdir -p /home/node/.n8n
  chown -R node:node /home/node/.n8n || true
fi

print_banner

# Drop privileges to 'node' and exec original n8n entrypoint
exec su-exec node /docker-entrypoint.sh "$@"
