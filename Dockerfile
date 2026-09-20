FROM hetsh/alpine:20260805-5
ARG LAST_UPGRADE="2026-09-20T08:24:36+02:00"
RUN apk upgrade --no-cache && \
	apk add --no-cache \
		ca-certificates=20260909-r0 \
		headscale=0.29.3-r0

ARG APP_USER="headscale"
ARG APP_GROUP="$APP_USER"
ARG NEW_UID="1378"
ARG NEW_GID="$NEW_UID"
ARG OLD_UID="101"
ARG OLD_GID="102"
RUN sed -i "s/:$OLD_UID:$OLD_GID:/:$NEW_UID:$NEW_GID:/" "/etc/passwd" && \
	sed -i "s/:$OLD_GID/:$NEW_GID:/" "/etc/group"

ARG RUN_DIR="/run/headscale"
ARG DATA_DIR="/var/lib/headscale"
RUN mkdir \
		"$RUN_DIR" \
		"$DATA_DIR" && \
	chown -R "$APP_USER:$APP_GROUP" \
		"/var/lib/headscale" \
		"$RUN_DIR" \
		"$DATA_DIR"

USER "$APP_USER"
ENTRYPOINT ["headscale"]
CMD ["serve"]
