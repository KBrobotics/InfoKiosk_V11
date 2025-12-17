# ========= BUILD STAGE =========
FROM node:20-alpine AS build

WORKDIR /app

# Pozwala budować, gdy frontend jest np. w /frontend
ARG APP_DIR=.
# Pozwala dopasować output: dist / build / out / itp.
ARG BUILD_DIR=dist

# Corepack obsługuje pnpm/yarn bez global install
RUN corepack enable

# Kopiujemy manifesty zależności (jeśli są) dla cache
# (kopiujemy cały katalog app później)
COPY ${APP_DIR}/package.json /app/package.json
COPY ${APP_DIR}/package-lock.json /app/package-lock.json
COPY ${APP_DIR}/pnpm-lock.yaml /app/pnpm-lock.yaml
COPY ${APP_DIR}/yarn.lock /app/yarn.lock

# Instalacja zależności - wybiera właściwy manager
RUN sh -lc '\
  if [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile; \
  elif [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  else npm install; \
  fi'

# Teraz kopiujemy cały kod aplikacji
COPY ${APP_DIR} /app

# Build
RUN sh -lc '\
  if [ -f pnpm-lock.yaml ]; then pnpm run build; \
  elif [ -f yarn.lock ]; then yarn build; \
  else npm run build; \
  fi'

# Sprawdź, czy katalog builda istnieje (czytelny błąd)
RUN test -d "/app/${BUILD_DIR}"


# ========= RUNTIME STAGE (NGINX) =========
FROM nginx:alpine

RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

ARG BUILD_DIR=dist
COPY --from=build /app/${BUILD_DIR} /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
