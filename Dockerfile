# Stage 1: Build the Flutter Web App
FROM debian:latest AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y curl git wget unzip xz-utils libglu1-mesa python3

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor and enable web
RUN flutter doctor -v
RUN flutter config --enable-web

# Copy project files and build
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve the app with Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
