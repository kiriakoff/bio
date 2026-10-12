FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY pubspec.yaml ./
RUN flutter config --enable-web
RUN flutter pub get
COPY web/ web/
COPY assets/ assets/
COPY lib/ lib/
COPY tool/ tool/
RUN flutter build web --release
# Injects the file size map for the loader and prunes unused engines.
RUN dart run tool/prepare_web.dart


FROM nginx:alpine

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
