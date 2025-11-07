# -------------------------------------------------------------
# Etapa 1: Construcción de la aplicación React
# -------------------------------------------------------------
FROM node:18-alpine AS build
WORKDIR /app

# Copia dependencias y las instala (usa cache eficiente)
COPY package*.json ./
RUN npm install --silent

# Copia el resto del código y ejecuta build de producción
COPY . .
RUN npm run build

# -------------------------------------------------------------
# Etapa 2: Servir archivos estáticos con Nginx (ajustado a OpenShift)
# -------------------------------------------------------------
FROM nginx:alpine

# Copia los archivos compilados del build anterior
COPY --from=build /app/build /usr/share/nginx/html

# Crear un directorio de caché accesible para el usuario no root (OpenShift)
RUN mkdir -p /tmp/nginx_cache /var/cache/nginx \
    && chmod -R 777 /tmp/nginx_cache /var/cache/nginx

# Ajustar configuración de Nginx:
# - Cambiar puerto a 8080 (no requiere root)
# - Cambiar rutas de cache a /tmp/nginx_cache
RUN sed -i 's|listen\s\+80;|listen 8080;|g' /etc/nginx/conf.d/default.conf \
    && sed -i 's|/var/cache/nginx|/tmp/nginx_cache|g' \
    /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Variable de entorno usada por Nginx en tiempo de ejecución
ENV NGINX_CACHE_PATH=/tmp/nginx_cache

# Nginx escucha en el puerto 8080
EXPOSE 8080

# Ejecuta nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]
