FROM node:22-alpine

WORKDIR /dealdrop-app

COPY package*.json ./
RUN npm install

COPY . .

ARG FIRECRAWL_API_KEY
ENV FIRECRAWL_API_KEY=$FIRECRAWL_API_KEY

RUN npm run build

CMD ["npm", "start"]
