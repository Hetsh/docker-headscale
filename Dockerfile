FROM hetsh/alpine:20260805-1
ARG LAST_UPGRADE="2026-08-09T09:22:09+02:00"
RUN apk upgrade --no-cache && \
	apk add --no-cache \
		ca-certificates=20260611-r0

# Installation
ARG APP_VERSION=0.29.3
ARG APP_URL="https://github.com/juanfont/headscale/releases/download/v$APP_VERSION/headscale_${APP_VERSION}_linux_amd64"
ARG APP_PATH="/bin/headscale"
ARG RUN_PATH="/var/run/headscale"
ARG DATA_DIR="/var/lib/headscale"
ARG CONFIG_DIR="/etc/headscale"
ARG ASSETS_DIR="assets"
RUN wget --quiet -O "$APP_PATH" "$APP_URL" && \
	chmod +x "$APP_PATH" && \
	mkdir -p \
		"$DATA_DIR" \
		"$RUN_PATH" \
		"$CONFIG_DIR"
COPY "assets/config.yaml" "/$CONFIG_DIR/config.yaml"

# App user
ARG APP_UID=1378
ARG APP_USER="headscale"
ARG APP_GROUP="$APP_USER"
RUN adduser \
		--disabled-password \
		--uid "$APP_UID" \
		--no-create-home \
		--gecos "$APP_USER" \
		--shell /sbin/nologin \
		"$APP_USER" && \
	chown -R \
		"$APP_USER":"$APP_GROUP" \
		"$DATA_DIR" \
		"$RUN_PATH"

USER "$APP_USER"
ENTRYPOINT ["headscale"]
CMD ["serve", "--config", "/etc/headscale/config.yaml"]
