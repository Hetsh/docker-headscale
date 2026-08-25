# Headscale
Simple to set up [Headscale](https://headscale.net/) server, a self-hosted [Tailscale](https://tailscale.com/) control plane.

## Running the server
Headscale needs to be configured first.
Use the [official documentation](https://headscale.net/stable/getting-started/) and the [sample configuration](https://github.com/juanfont/headscale/blob/main/config-example.yaml) to get started.
Note that `server_url` must be publicly reachable (https recommended).

This image starts `headscale` with parameters `serve --config /config/config.yaml`.
However, you can override them:
```bash
docker run ... hetsh/headscale <command> <parameters>
```

```bash
docker run \
    --detach \
    --name headscale \
    --publish 8080:8080/tcp \
    --mount type=bind,source=/path/to/config,target=/config \
    --mount type=bind,source=/path/to/data,target=/var/lib/headscale \
    hetsh/headscale
```
Optional additional ports:
- `50443/tcp`: gRPC interface for remote CLI access
- `9090/tcp`: metrics endpoint
- `443/tcp` and `80/tcp`: built-in Let's Encrypt certificate handling
- `3478/udp`: STUN for the embedded DERP relay

## Stopping the container
```bash
docker stop headscale
```

## Creating persistent storage
```bash
CONFIG="/path/to/config"
DATA="/path/to/data"
mkdir -p "$CONFIG" "$DATA"
chown 1378:1378 "$CONFIG" "$DATA"
```
`1378` is the numerical id of the user running the server (see Dockerfile).
The user must have RW access to these directories.
The config directory must contain the `config.yaml` file.
The data directory will hold the SQLite database and the Noise private key.
Start the server with the additional mount flags:
```bash
docker run \
    --mount type=bind,source=/path/to/config,target=/config \
    --mount type=bind,source=/path/to/data,target=/var/lib/headscale \
    ...
```

## Managing the tailnet
The `headscale` CLI talks to the running server over its unix socket (created at `/var/run/headscale/headscale.sock` by default).
Run CLI commands inside the container:
```bash
docker exec -it headscale headscale --config /config/config.yaml users list
```
Create a user and a preauth key for it:
```bash
docker exec -it headscale headscale --config /config/config.yaml users create myuser
docker exec -it headscale headscale --config /config/config.yaml preauthkeys create --user 1
```

## Time
Synchronizing the timezones will display the correct time in the logs.
The timezone can be shared with this mount flag:
```bash
docker run \
    --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
    ...
```

## Setup
After the server is running, create a user and a preauth key (see above).
Then connect a Tailscale client to the tailnet:
```bash
tailscale up --login-server https://headscale.example.com --auth-key <key>
```

## Automate startup and shutdown via systemd
The systemd unit can be found in my GitHub [repository](https://github.com/Hetsh/docker-headscale).
```bash
systemctl enable headscale --now
```
By default, the systemd service assumes `/apps/headscale/config` for config, `/apps/headscale/data` for data and `/etc/localtime` for timezone.
Since this is a personal systemd unit file, you might need to adjust some parameters to suit your setup.

## Fork Me!
This is an open project hosted on [GitHub](https://github.com/Hetsh/docker-headscale).
Please feel free to ask questions, file an issue or contribute to it.
