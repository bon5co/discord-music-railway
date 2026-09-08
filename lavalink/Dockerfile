# Lavalink v4 audio server, packaged for Railway.
#
# Differences from the stock image:
#   * the YouTube source plugin is baked into the image, so the container needs
#     no network access at boot (stock Lavalink downloads plugin jars from
#     maven.lavalink.dev on every start and refuses to boot if that fails);
#   * an nginx gateway listens on Railway's injected $PORT and exposes an
#     unauthenticated /healthz that proxies an authenticated request to
#     Lavalink's own /version, so a Railway healthcheck can prove the engine is
#     actually up. Every route except /healthz is passed through unchanged,
#     including the /v4/websocket upgrade.
FROM ghcr.io/lavalink-devs/lavalink@sha256:87ae53e60dc147c9dddb28e126ce503a26bc8d1477ed8d99543614677882afff

ARG YOUTUBE_PLUGIN_VERSION=1.18.2

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends nginx curl ca-certificates gettext-base \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/Lavalink/plugins \
 && curl -fsSL -o /opt/Lavalink/plugins/youtube-plugin-${YOUTUBE_PLUGIN_VERSION}.jar \
      https://maven.lavalink.dev/releases/dev/lavalink/youtube/youtube-plugin/${YOUTUBE_PLUGIN_VERSION}/youtube-plugin-${YOUTUBE_PLUGIN_VERSION}.jar \
 && test "$(stat -c %s /opt/Lavalink/plugins/youtube-plugin-${YOUTUBE_PLUGIN_VERSION}.jar)" -gt 1000000 \
 && chown -R lavalink:lavalink /opt/Lavalink/plugins

COPY nginx.conf.template /opt/railway/nginx.conf.template
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
