# Stage 1: Build stage using an active, secure LTS version of Node on Alpine
FROM node:20-alpine AS builder
WORKDIR /app
COPY ./package.json .
COPY ./yarn.lock .
RUN yarn install --frozen-lockfile
COPY . .
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"
RUN yarn build

# Stage 2: Final production stage using the latest stable Nginx on Alpine
FROM nginx:alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*

# Upgrade system packages immediately to patch remaining baseline OS vulnerabilities
RUN apk update && apk upgrade --no-cache

COPY --from=builder /app/dist .
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
