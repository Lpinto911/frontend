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

# Ajuste para OpenShift: redirige cache y temporales a /tmp
RUN mkdir -p /tmp/nginx_cache && chmod -R 777 /tmp/nginx_cache
RUN sed -i 's|/var/cache/nginx|/tmp/nginx_cache|g' /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Nginx escucha en el puerto 8080 (recomendado para OpenShift)
EXPOSE 8080

# Ejecuta nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]
