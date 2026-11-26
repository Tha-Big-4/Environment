# Generic static-site image for any JS framework: build with Node, serve with unprivileged nginx.
# Override BUILD_CMD / DIST_DIR for your framework (e.g. DIST_DIR=dist/<app>/browser for Angular).
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json pnpm-lock.yaml* yarn.lock* ./
RUN if [ -f pnpm-lock.yaml ]; then corepack enable && pnpm i --frozen-lockfile; \
    elif [ -f yarn.lock ]; then corepack enable && yarn install --frozen-lockfile; \
    else npm ci; fi
COPY . .
ARG BUILD_CMD="npm run build"
RUN sh -c "$BUILD_CMD"

FROM nginxinc/nginx-unprivileged:1.27-alpine
ARG DIST_DIR=dist
COPY --from=build /app/${DIST_DIR} /usr/share/nginx/html
COPY --from=envdocker nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
HEALTHCHECK CMD wget -qO- http://127.0.0.1:8080/ >/dev/null || exit 1
