# Stage 1: Build AIRI stage-web
FROM node:20-alpine AS builder

# Install system deps for native modules
RUN apk add --no-cache git python3 make g++ curl bash \
    cairo-dev pango-dev jpeg-dev giflib-dev librsvg-dev pixman-dev \
    pkgconfig fontconfig-dev

WORKDIR /build

# Clone only the packages needed for stage-web
RUN git clone --depth=1 https://github.com/moeru-ai/airi.git /airi-full

# Copy only stage-web and its workspace dependencies
RUN cp -r /airi-full/apps/stage-web /build/stage-web && \
    cp /airi-full/package.json /build/ && \
    cp /airi-full/pnpm-workspace.yaml /build/ && \
    mkdir -p /build/packages && \
    for pkg in /airi-full/packages/*/; do cp -r "$pkg" /build/packages/; done

# Copy pnpm-lock.yaml
RUN cp /airi-full/pnpm-lock.yaml /build/ 2>/dev/null || true

# Install pnpm
RUN npm install -g pnpm@9

# Install only stage-web dependencies, ignore optional native modules
RUN cd /build && pnpm install --no-frozen-lockfile --ignore-scripts 2>&1 || \
    pnpm install --no-frozen-lockfile --ignore-scripts --shamefully-hoist

# Build stage-web
RUN cd /build/stage-web && pnpm build

# Stage 2: Serve with nginx
FROM nginx:alpine

COPY --from=builder /build/stage-web/dist /usr/share/nginx/html

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
