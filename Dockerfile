FROM node:22-alpine

WORKDIR /dealdrop-app

COPY package*.json ./
RUN npm install

COPY . .

RUN --mount=type=secret,id=app_config \
    cat /run/secrets/app_config > ./config_internal.json && \
    npm run build

CMD ["npm", "start"]
