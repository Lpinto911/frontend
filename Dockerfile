# Dockerfile for frontend (React) - builds the app and serves with nginx
FROM node:18-alpine as build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --silent
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
# Nginx listens on 80; OpenShift route will map to service port 80
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
