FROM node:22-alpine

WORKDIR /dealdrop-app

COPY package*.json ./
RUN npm install

COPY . .

RUN --mount=type=secret,id=app_env \
    cp /run/secrets/app_env .env && \
    npm run build && \
    rm .env

CMD ["npm", "start"]
