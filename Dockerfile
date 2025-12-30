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
    # Automatically export all variables from the secret file to the environment
    npm run build


CMD ["npm", "start"]
