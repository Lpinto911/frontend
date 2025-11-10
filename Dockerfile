# -------------------------------------------------------------
# Etapa 1: Construcción de la aplicación React
# -------------------------------------------------------------
FROM node:18-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm install --silent

COPY . .
RUN npm run build

# -------------------------------------------------------------
# Etapa 2: Servir con Nginx (ajustado a OpenShift)
# -------------------------------------------------------------
FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

# Crear directorios accesibles al usuario no root
RUN mkdir -p /tmp/nginx_cache /tmp/run \
    && chmod -R 777 /tmp/nginx_cache /tmp/run /var/cache/nginx

# Ajustar configuración para usar rutas accesibles
RUN sed -i 's|/var/cache/nginx|/tmp/nginx_cache|g' \
    /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf \
 && sed -i 's|/run/nginx.pid|/tmp/run/nginx.pid|g' /etc/nginx/nginx.conf

# Cambiar el puerto de escucha a 8080
RUN sed -i 's|listen       80;|listen       8081;|g' /etc/nginx/conf.d/default.conf

EXPOSE 8081
ENV NGINX_CACHE_PATH=/tmp/nginx_cache

CMD ["nginx", "-g", "daemon off;"]
