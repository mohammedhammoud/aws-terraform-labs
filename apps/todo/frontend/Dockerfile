FROM node:22-alpine AS deps

WORKDIR /app

COPY package*.json ./
COPY shared/package.json shared/package.json
COPY backend/package.json backend/package.json
COPY frontend/package.json frontend/package.json

RUN npm ci

FROM deps AS build

WORKDIR /app

COPY . .

ENV VITE_API_URL=http://localhost:3001

RUN npm run build --workspace @todo/shared \
  && npm run build --workspace @todo/frontend

FROM nginx:1.27-alpine AS runtime

RUN apk add --no-cache gettext

ENV VITE_API_URL=http://localhost:3001

COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf
COPY frontend/docker-entrypoint.sh /docker-entrypoint.sh
COPY frontend/config.template.json /usr/share/nginx/html/config.template.json
COPY --from=build /app/frontend/dist /usr/share/nginx/html

RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

CMD ["/docker-entrypoint.sh"]
