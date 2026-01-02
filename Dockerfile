# syntax=docker/dockerfile:1

FROM node:22-alpine

RUN apk add --no-cache libc6-compat

WORKDIR /dealdrop-app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

CMD ["npx", "next", "start"]
