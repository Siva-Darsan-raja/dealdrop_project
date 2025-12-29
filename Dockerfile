# syntax=docker/dockerfile:1
FROM node:22-alpine

# Set working directory
WORKDIR /dealdrop-app

# Install dependencies first (better caching)
COPY package*.json ./
RUN npm install

# Copy application source
COPY . .

# Use the secret ONLY for the build process
# The secret is NOT saved in the final image layers
RUN --mount=type=secret,id=app_config \
    set -a && . /run/secrets/app_config && set +a && \
    npm run build
# If the app NEEDS that config at runtime, do NOT use RUN --mount.
# Instead, mount it when starting the container (docker run -v ...)

CMD ["npm", "start"]
