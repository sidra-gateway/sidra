cd /app/sidra-config && ./sidra-proxy &
cd /app/sidra-plugins-hub && ./sidra-plugins-hub &
nginx -g 'daemon off;'