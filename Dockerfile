FROM hetsh/alpine:20260805-3
ARG LAST_UPGRADE="2026-08-09T09:22:09+02:00"
RUN apk upgrade --no-cache && \
	apk add --no-cache \
		ca-certificates=20260611-r0 \
		headscale=0.29.3-r0

ARG APP_USER="headscale"
ARG APP_GROUP="$APP_USER"
ARG APP_UID="1378"
ARG APP_GID="$APP_UID"
RUN groupmod --gid "$APP_GID" "$APP_GROUP" && \
	usermod --uid "$APP_UID" "$APP_USER"

ARG RUN_DIR="/run/headscale"
ARG DATA_DIR="/var/lib/headscale"
RUN mkdir \
		"$RUN_DIR" \
		"$DATA_DIR" && \
	chown -R "$APP_USER:$APP_GROUP" \
		"$RUN_DIR" \
		"$DATA_DIR"

USER "$APP_USER"
ENTRYPOINT ["headscale"]
CMD ["serve"]
