# Build stage
FROM node:20-alpine3.18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev  # Install only production dependencies
COPY . .
RUN npm run build

# Production stage
FROM nginx:1.25.3-alpine3.18
WORKDIR /usr/share/nginx/html

# Security: Remove unnecessary files and users
RUN rm -rf /var/cache/apk/* /tmp/* /var/tmp/* \
    && rm -rf /etc/nginx/conf.d/default.conf

COPY --from=build /app/dist ./
# Add nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Use non-root user for security
RUN adduser -D -H -s /sbin/nologin nginxuser \
    && chown -R nginxuser:nginxuser /usr/share/nginx/html
USER nginxuser

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
