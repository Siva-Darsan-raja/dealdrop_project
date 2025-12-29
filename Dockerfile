FROM node:22-alpine

WORKDIR /dealdrop-app

COPY package*.json ./
RUN npm install

COPY . .
COPY $ENV .

RUN npm run build

CMD ["npm", "start"]
