# syntax=docker/dockerfile:1
FROM node:22-alpine

# Set working directory
WORKDIR /dealdrop-app

# Install dependencies first (better caching)
COPY package*.json ./
RUN npm install

# Copy application source
COPY . .

RUN --mount=type=secret,id=app_config \
    export $(grep -v '^#' /run/secrets/app_config | tr -d '\r' | xargs) && \
    npm run build


CMD ["npm", "start"]
