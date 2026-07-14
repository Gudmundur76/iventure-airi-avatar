# Stage 1: Build AIRI stage-web
FROM node:20-alpine AS builder

RUN apk add --no-cache git python3 make g++ curl bash

WORKDIR /build

# Clone AIRI (shallow clone for speed)
RUN git clone --depth=1 https://github.com/moeru-ai/airi.git .

# Install pnpm
RUN npm install -g pnpm@9

# Install dependencies
RUN pnpm install --frozen-lockfile

# Download Live2D SDK (required for build)
RUN mkdir -p apps/stage-web/public/assets/js && \
    curl -sL "https://github.com/moeru-ai/airi/releases/download/v0.1.0/CubismSdkForWeb-5-r.3.zip" \
    -o /tmp/cubism.zip 2>/dev/null || true

# Build stage-web
WORKDIR /build/apps/stage-web
RUN pnpm build

# Stage 2: Serve with nginx
FROM nginx:alpine

COPY --from=builder /build/apps/stage-web/dist /usr/share/nginx/html

# nginx config for SPA routing
RUN echo 'server { \
    listen 80; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    add_header Cache-Control "no-cache, no-store, must-revalidate"; \
    add_header X-Frame-Options SAMEORIGIN; \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
