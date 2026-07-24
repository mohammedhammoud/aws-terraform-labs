#!/bin/sh
set -eu

envsubst '${VITE_API_URL}' < /usr/share/nginx/html/config.template.json > /usr/share/nginx/html/config.json

exec nginx -g 'daemon off;'
