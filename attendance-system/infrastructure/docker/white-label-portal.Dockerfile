# Build stage
FROM node:20-alpine AS build
WORKDIR /app

# Copy package files
COPY white-label-portal/package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY white-label-portal/ .

# Build the application
RUN npm run build:prod

# Runtime stage with Nginx
FROM nginx:alpine AS runtime

# Copy custom nginx config
COPY infrastructure/docker/nginx/portal.conf /etc/nginx/conf.d/default.conf

# Copy built files
COPY --from=build /app/dist/white-label-admin-portal/browser /usr/share/nginx/html

# Create non-root user
RUN addgroup -g 1001 -S appgroup \
    && adduser -u 1001 -S appuser -G appgroup \
    && chown -R appuser:appgroup /usr/share/nginx/html \
    && chown -R appuser:appgroup /var/cache/nginx \
    && chown -R appuser:appgroup /var/log/nginx \
    && touch /var/run/nginx.pid \
    && chown -R appuser:appgroup /var/run/nginx.pid

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
