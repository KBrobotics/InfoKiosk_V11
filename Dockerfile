# ========= BUILD STAGE =========
FROM node:20-alpine AS build

WORKDIR /app

# Instalacja zależności (cache-friendly)
COPY package.json package-lock.json* ./
RUN npm install

# Kod źródłowy
COPY . .

# Build Vite (TypeScript -> JS + bundling)
RUN npm run build

# Bezpiecznik: upewnij się, że dist istnieje
RUN test -d /app/dist


# ========= RUNTIME STAGE =========
FROM nginx:alpine

RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Statyczne pliki z Vite
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
