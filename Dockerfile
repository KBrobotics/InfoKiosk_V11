# ========= BUILD STAGE =========
FROM node:20-alpine AS build

WORKDIR /app

# Najpierw zależności (lepsze cache)
COPY package*.json ./
# Jeśli masz lock inny niż package-lock.json (np. pnpm-lock.yaml / yarn.lock),
# to dopasuj komendy poniżej.
RUN npm ci

# Kod aplikacji
COPY . .

# Build (powinien wygenerować /app/dist)
RUN npm run build


# ========= RUNTIME STAGE (NGINX) =========
FROM nginx:alpine

# Usuń domyślną konfigurację
RUN rm -f /etc/nginx/conf.d/default.conf

# Twoja konfiguracja nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Skopiuj zbudowane pliki statyczne
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
