# discord-music-railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/discord-music-bot-or-just-updated-lavali?referralCode=Z1xivh&utm_medium=integration&utm_source=template&utm_campaign=generic)

**Deploy on Railway:** [Discord Music Bot template](https://railway.com/deploy/discord-music-bot-or-just-updated-lavali?referralCode=Z1xivh&utm_medium=integration&utm_source=template&utm_campaign=generic)

Wrapper images for a Railway template that deploys a Discord music bot together with
its own Lavalink audio server.

* `lavalink/` — [Lavalink](https://github.com/lavalink-devs/Lavalink) v4 with the
  YouTube source plugin baked into the image (stock Lavalink downloads plugin jars
  from `maven.lavalink.dev` on every boot and refuses to start if that fails), plus a
  small nginx gateway that listens on Railway's injected `$PORT` and serves an
  unauthenticated `/healthz` by proxying an authenticated request to Lavalink's own
  `/version` — so a Railway healthcheck can prove the engine answered. Every other
  route, including the `/v4/websocket` upgrade, is passed through unchanged.
  The container refuses to start on an empty `LAVALINK_SERVER_PASSWORD`.

* `bot/` — [LavaMusic](https://github.com/appujet/lavamusic) 4.6.7 with its SQLite
  database moved onto a Railway volume at `/data`, the hardcoded default search
  engine made configurable through `SEARCH_ENGINE` (defaulting to SoundCloud, which
  resolves reliably from a datacentre IP), and a refusal to start on an empty
  `TOKEN`, `CLIENT_ID`, `LAVALINK_URL` or `LAVALINK_AUTH`.

Images are published to GHCR by `.github/workflows/build.yml`.
