# Stage 1: Build semua plugin dan konfigurasi
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Salin kode sumber untuk semua plugin dan konfigurasi
COPY plugins/plugin-basic-auth ./plugins/plugin-basic-auth
COPY plugins/plugin-jwt ./plugins/plugin-jwt
COPY plugins/plugin-whitelist ./plugins/plugin-whitelist
COPY plugins/plugin-cache ./plugins/plugin-cache
COPY plugins/plugin-ratelimit ./plugins/plugin-ratelimit
COPY sidra-config ./sidra-config
COPY sidra-plugins-hub ./sidra-plugins-hub

# Build semua plugin
RUN for dir in ./plugins/*; do \
    if [ -d "$dir" ]; then \
        echo "Building $(basename $dir)..."; \
        cd $dir && go mod tidy && go build -o /app/build/$(basename $dir); \
        cd -; \
    fi; \
done

RUN cd sidra-config && go mod tidy && go build -o /app/sidra-config;


# Stage 2: Menjalankan container dengan nginx dan plugin
FROM nginx:latest

WORKDIR /app

# Salin hasil build dan konfigurasi ke dalam container
COPY --from=builder /app/build /app/plugins
COPY --from=builder /app/sidra-config /app/sidra-config
COPY --from=builder /app/sidra-plugins-hub /app/sidra-plugins-hub
COPY --from=builder /app/sidra-config /app/sidra-config

# Salin konfigurasi nginx
COPY config/nginx.conf /etc/nginx/conf.d/sidra.conf
COPY sidra-plugins-hub /app/sidra-plugins-hub

# Menyediakan akses ke port 8080
EXPOSE 8080 3033

# Salin skrip run.sh
COPY run.sh /app/run.sh

# Set default command untuk menjalankan aplikasi
CMD ["bash", "/app/run.sh"]
