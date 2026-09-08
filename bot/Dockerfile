# LavaMusic Discord bot, packaged for Railway.
#
# Differences from the stock image:
#   * the SQLite database is moved onto a Railway volume at /data. Upstream
#     hardcodes `url = "file:./lavamusic.db"` in schema.prisma (it is not an
#     env() reference), and that path sits next to the pre-seeded database in
#     the image -- so mounting a volume over prisma/ would hide both the schema
#     and the seeded database. The entrypoint instead seeds /data on first boot
#     and symlinks the image path at it, which also keeps the -wal and -shm
#     files on the volume;
#   * the default search engine is configurable. Upstream hardcodes
#     `searchEngine: SearchEngine.YouTube` in dist/config.js, and unauthenticated
#     YouTube playback from a datacentre IP is not dependable, so the default
#     here is SoundCloud and SEARCH_ENGINE selects any other;
#   * the container refuses to start on an empty bot token, client id or
#     Lavalink address instead of crash-looping with a discord.js stack trace.
FROM ghcr.io/appujet/lavamusic@sha256:a076712694affa7d0ed7239e3bfd6cc86f41cc65fa95288be421452b59b4b154

USER root

# Make the hardcoded search engine an environment variable. The grep assertion
# means an upstream change to this line fails the build rather than silently
# shipping stock behaviour.
RUN grep -q 'searchEngine: SearchEngine.YouTube,' /opt/lavamusic/dist/config.js \
 && sed -i 's|searchEngine: SearchEngine.YouTube,|searchEngine: SearchEngine[process.env.SEARCH_ENGINE] ?? SearchEngine.SoundCloud,|' /opt/lavamusic/dist/config.js \
 && grep -q 'SearchEngine\[process.env.SEARCH_ENGINE\]' /opt/lavamusic/dist/config.js

# Pristine copy of the seeded database, used to seed the volume on first boot.
RUN cp /opt/lavamusic/prisma/lavamusic.db /opt/lavamusic-seed.db

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["node", "dist/index.js"]
