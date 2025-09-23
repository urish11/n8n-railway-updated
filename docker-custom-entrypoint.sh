#!/bin/sh
set -e

print_banner() {
  echo "----------------------------------------"
  echo "n8n Puppeteer Node - Environment Details"
  echo "----------------------------------------"
  echo "Node.js: $(node -v)"
  echo "n8n: $(n8n --version || true)"
  CHROME_VERSION=$("$PUPPETEER_EXECUTABLE_PATH" --version 2>/dev/null || echo "Chromium not found")
  echo "Chromium: $CHROME_VERSION"
  echo "Puppeteer exec path: $PUPPETEER_EXECUTABLE_PATH"
  echo "Puppeteer extra args: $PUPPETEER_ARGS"
  echo "Custom nodes dir: $N8N_CUSTOM_EXTENSIONS"
  echo "----------------------------------------"
}

# Last-mile fix in case the mounted Railway volume comes in with root perms
if [ -d "/home/node/.n8n" ]; then
  chown -R node:node /home/node/.n8n 2>/dev/null || true
fi

print_banner

# Export sane defaults even if not set
export PUPPETEER_ARGS="${PUPPETEER_ARGS:-"--no-sandbox --disable-dev-shm-usage --headless=new"}"

# Hand off to the original n8n entrypoint
exec /docker-entrypoint.sh "$@"
