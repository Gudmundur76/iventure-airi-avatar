# Stage 1: Build AIRI stage-web
# Use Debian-based image for full native module support (glibc required by canvas, node-pty, isolated-vm)
FROM node:20-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3 make g++ curl \
    libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev \
    libpixman-1-dev pkg-config libfontconfig1-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Clone AIRI
RUN git clone --depth=1 https://github.com/moeru-ai/airi.git .

# Install pnpm
RUN npm install -g pnpm@9

# Install all dependencies (full monorepo, with native module compilation)
# Install dependencies - allow install to proceed even if optional native modules fail
RUN pnpm install --no-frozen-lockfile 2>&1 | tail -20 || \
    pnpm install --no-frozen-lockfile --ignore-scripts 2>&1 | tail -20

# Ensure vite binary is available by running install in stage-web dir
RUN cd /build/apps/stage-web && \
    node_modules/.bin/vite --version 2>/dev/null || \
    (pnpm install --no-frozen-lockfile --ignore-scripts && echo "stage-web deps installed")

# Build stage-web using local node_modules/.bin/vite
WORKDIR /build/apps/stage-web
RUN node_modules/.bin/vite build || \
    (pnpm install --no-frozen-lockfile && node_modules/.bin/vite build)

# Stage 2: Serve with nginx
FROM nginx:alpine

COPY --from=builder /build/apps/stage-web/dist /usr/share/nginx/html

# nginx config for SPA routing
RUN printf 'server {\n  listen 80;\n  root /usr/share/nginx/html;\n  index index.html;\n  location / {\n    try_files $uri $uri/ /index.html;\n  }\n  add_header Cache-Control "no-cache, no-store, must-revalidate";\n}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 80
