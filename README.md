
# deploy.sh

This script is used to manage Docker Wemx containers.

## Usage

```
./deploy.sh [options]
```

### Options:

- `-c, --console`         - Start a bash console inside a wemx container.
- `--down`                - Stop all Wemx Docker containers.
- `--up`                  - Run all Wemx Docker containers.
- `--restart`             - Restart all Wemx Docker containers.
- `--rebuild`             - Rebuild all Wemx Docker containers.
- `-h, --help`            - Show this help message and exit.

## Example of Use

Starting the console inside the container:
```
./deploy.sh --console
```

Stopping all containers:
```
./deploy.sh --down
```

Starting all containers:
```
./deploy.sh --up
```

## Settings

Before running the script, make sure that the `.env` file exists and contains all necessary environment variables.

### Database Configuration

- If `DB_HOST=db` in the `.env` file, the database will be created inside the container.
- If `DB_HOST` is set to something else, the script will try to connect to an existing database.

## Network Settings for Traefik

If you are using Traefik, you need to replace the `proxy` network with the network used by Traefik. For example:

```yaml
networks:
  proxy:
    external: true
```
replace with:
```yaml
networks:
  traefik-network-name:
    external: true
```
and replace the `proxy` network with `traefik-network-name` in the service definitions:
```yaml
    networks:
      - proxy
```
replace with:
```yaml
    networks:
      - traefik-network-name
```