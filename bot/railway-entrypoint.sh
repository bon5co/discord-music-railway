#!/bin/sh
set -eu

log() { echo "[railway] $*"; }
fatal() { echo "[railway] FATAL: $*" >&2; exit 1; }

[ -n "${TOKEN:-}" ] || fatal "TOKEN is empty. Create a bot at https://discord.com/developers/applications and paste its token."
[ -n "${CLIENT_ID:-}" ] || fatal "CLIENT_ID is empty. It is the application ID of that same bot."
[ -n "${LAVALINK_URL:-}" ] || fatal "LAVALINK_URL is empty. It must be host:port of the Lavalink service."
[ -n "${LAVALINK_AUTH:-}" ] || fatal "LAVALINK_AUTH is empty. It must match the Lavalink service's password."

DATA_DIR=/data
DB=$DATA_DIR/lavamusic.db

# Railway mounts volumes owned by uid 0 and this image runs as uid 322.
if [ -d "$DATA_DIR" ]; then
  owner=$(stat -c %u:%g "$DATA_DIR")
  if [ "$owner" != "322:65534" ]; then
    log "volume owned by $owner, repairing to 322:65534"
    chown -R 322:65534 "$DATA_DIR"
  fi
else
  mkdir -p "$DATA_DIR" && chown 322:65534 "$DATA_DIR"
fi

if [ ! -f "$DB" ]; then
  log "seeding $DB from the image's database"
  cp /opt/lavamusic-seed.db "$DB"
  chown 322:65534 "$DB"
fi

# schema.prisma hardcodes file:./lavamusic.db, so point that path at the volume.
ln -sf "$DB" /opt/lavamusic/prisma/lavamusic.db

log "search engine: ${SEARCH_ENGINE:-SoundCloud}; lavalink: ${LAVALINK_URL}"

cd /opt/lavamusic
exec setpriv --reuid=322 --regid=65534 --clear-groups "$@"
