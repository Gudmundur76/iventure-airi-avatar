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
RUN pnpm install --no-frozen-lockfile 2>&1 | tail -20

# Build stage-web
# Build stage-web using pnpm filter from monorepo root (so vite binary is found)
WORKDIR /build
RUN pnpm --filter @proj-airi/stage-web build

# Stage 2: Serve with nginx
FROM nginx:alpine

COPY --from=builder /build/apps/stage-web/dist /usr/share/nginx/html

# nginx config for SPA routing
RUN printf 'server {\n  listen 80;\n  root /usr/share/nginx/html;\n  index index.html;\n  location / {\n    try_files $uri $uri/ /index.html;\n  }\n  add_header Cache-Control "no-cache, no-store, must-revalidate";\n}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 80
