FROM hetsh/alpine:20260805-1
ARG LAST_UPGRADE="2026-08-09T09:22:09+02:00"
RUN apk upgrade --no-cache && \
	apk add --no-cache \
		ca-certificates=20260611-r0

# App user
ARG APP_UID=1378
ARG APP_USER="headscale"
ARG DATA_DIR="/var/lib/headscale"
RUN adduser \
		--disabled-password \
		--uid "$APP_UID" \
		--home "$DATA_DIR" \
		--gecos "$APP_USER" \
		--shell /sbin/nologin \
		"$APP_USER" && \
	mkdir -p /config /var/run/headscale && \
	chown "$APP_USER" /config /var/run/headscale

# Installation
ARG APP_VERSION=0.29.3
ARG BASE_URL="https://github.com/juanfont/headscale/releases/download/v$APP_VERSION"
ARG BINARY="headscale_${APP_VERSION}_linux_amd64"
RUN wget --quiet -O "/usr/bin/headscale" "$BASE_URL/$BINARY" && \
	chmod +x "/usr/bin/headscale"

# Default configuration (override by mounting your own /config)
COPY --chown="$APP_USER" config.yaml /config/config.yaml

USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENTRYPOINT ["headscale"]
CMD ["serve", "--config", "/config/config.yaml"]
