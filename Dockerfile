FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html

RUN printf 'server {\n  listen 80;\n  root /usr/share/nginx/html;\n  index index.html;\n  location / {\n    try_files $uri $uri/ /index.html;\n  }\n  add_header Cache-Control "no-cache, no-store, must-revalidate";\n  add_header X-Frame-Options SAMEORIGIN;\n  gzip on;\n  gzip_types text/html text/css application/javascript;\n}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 80
