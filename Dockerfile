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
    set -a && . /run/secrets/app_config && set +a && \
    npm run build


CMD ["npm", "start"]
