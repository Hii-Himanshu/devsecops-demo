# Build stage
FROM node:20-alpine3.18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:1.25.3-alpine3.18
WORKDIR /usr/share/nginx/html
RUN apk --no-cache add libxml2=2.10.4-r7 \
    && rm -rf /var/cache/apk/*
COPY --from=build /app/dist ./
# Add nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
