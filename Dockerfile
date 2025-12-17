# Prosty obraz NGINX do serwowania plików statycznych (kiosk / SPA)
FROM nginx:alpine

# Usuwamy domyślną konfigurację NGINX
RUN rm -f /etc/nginx/conf.d/default.conf

# Kopiujemy własną konfigurację
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Kopiujemy pliki aplikacji do katalogu serwowanego przez NGINX
# Załóżmy, że gotowy build frontendu jest w ./dist (często: dist albo build)
# Jeśli u Ciebie katalog nazywa się inaczej (np. build/), zmień ścieżkę poniżej.
COPY ./dist /usr/share/nginx/html

EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
