# ========= BUILD STAGE =========
FROM node:20-alpine AS build

WORKDIR /app

# Zależności (cache-friendly)
COPY package*.json ./
RUN npm ci

# Źródła aplikacji
COPY . .

# Budowa frontu -> powinno wygenerować /app/dist
RUN npm run build


# ========= RUNTIME STAGE (NGINX) =========
FROM nginx:alpine

# Usuń domyślną konfigurację NGINX
RUN rm -f /etc/nginx/conf.d/default.conf

# Skopiuj Twoją konfigurację
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Skopiuj build (dist) do katalogu serwowanego przez NGINX
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
