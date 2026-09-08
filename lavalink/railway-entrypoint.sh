#!/bin/sh
set -eu

log() { echo "[railway] $*"; }

if [ -z "${LAVALINK_SERVER_PASSWORD:-}" ]; then
  echo "[railway] FATAL: LAVALINK_SERVER_PASSWORD is empty." >&2
  echo "[railway] Lavalink would accept any client that reaches it." >&2
  exit 1
fi

# Railway injects PORT into every service, including private ones, and its
# healthcheck dials that port -- so the gateway, not Lavalink, owns it.
GATEWAY_PORT="${PORT:-2333}"
LAVALINK_INTERNAL_PORT=2333
if [ "$GATEWAY_PORT" = "$LAVALINK_INTERNAL_PORT" ]; then
  LAVALINK_INTERNAL_PORT=2334
fi
export GATEWAY_PORT LAVALINK_INTERNAL_PORT

# Lavalink reads Spring properties from the environment.
SERVER_PORT="$LAVALINK_INTERNAL_PORT"
SERVER_ADDRESS=127.0.0.1
export SERVER_PORT SERVER_ADDRESS

mkdir -p /tmp/nginx-body /tmp/nginx-proxy /tmp/nginx-fastcgi /tmp/nginx-uwsgi /tmp/nginx-scgi
envsubst '${GATEWAY_PORT} ${LAVALINK_INTERNAL_PORT} ${LAVALINK_SERVER_PASSWORD}' \
  < /opt/railway/nginx.conf.template > /tmp/nginx.conf

log "gateway on ${GATEWAY_PORT}, lavalink on 127.0.0.1:${LAVALINK_INTERNAL_PORT}"
log "plugins: $(ls /opt/Lavalink/plugins | tr '\n' ' ')"

nginx -c /tmp/nginx.conf &
NGINX_PID=$!

# If nginx dies the service is unreachable, so take the container down with it.
( while kill -0 "$NGINX_PID" 2>/dev/null; do sleep 10; done
  echo "[railway] FATAL: nginx exited" >&2; kill -TERM 1 ) &

cd /opt/Lavalink
exec setpriv --reuid=322 --regid=322 --init-groups java -jar Lavalink.jar
