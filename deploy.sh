#!/bin/bash

# Function to show help
show_help() {
    echo "Usage: ./deploy.sh [options]"
    echo ""
    echo "Options:"
    echo "  -c, --console        Start a bash console inside the wemx container"
    echo "  --down               Stop all Wemx Docker containers"
    echo "  --up                 Start all Wemx Docker containers"
    echo "  --restart            Restart all Wemx Docker containers"
    echo "  --rebuild            Rebuild all Wemx Docker containers"
    echo "  -h, --help           Show this help message and exit"
}

set_x_perms() {
    chmod +x "$1"
}

set_x_perms ".docker/php/install.sh"
set_x_perms ".docker/php/update.sh"
set_x_perms ".docker/php/run-cron.sh"
set_x_perms ".docker/php/wemx.sh"

# Argument parsing
ACTION=""

for arg in "$@"; do
    case $arg in
    -c | --console)
        docker-compose exec wemx bash
        exit 0
        ;;
    --down)
        ACTION="down"
        shift
        ;;
    --up)
        ACTION="up"
        shift
        ;;
    --restart)
        ACTION="restart"
        shift
        ;;
    --rebuild)
        ACTION="rebuild"
        shift
        ;;
    -h | --help)
        show_help
        exit 0
        ;;
    *)
        echo "Unknown option: $arg"
        show_help
        exit 1
        ;;
    esac
done

# Loading variables from .env file
if [ -f ".env" ]; then
    set -a
    source <(grep -v '^#' .env | sed 's/\r$//')
    set +a
else
    echo "Error: .env file not found."
    exit 1
fi

# Determine the appropriate docker-compose files
COMPOSE_FILES="-f docker-compose.yml"

if [ "$DB_HOST" = "db" ]; then
    COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.db.yml"
fi

if [ "$USE_TRAEFIK" = "true" ]; then
    COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.traefik.yml"
else
    COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.nginx.yml"
fi

# Perform actions based on the provided argument
case $ACTION in
    down)
        echo "Stopping all Docker containers with configuration: $COMPOSE_FILES"
        docker-compose $COMPOSE_FILES down
        ;;
    up)
        echo "Starting Docker Compose with configuration: $COMPOSE_FILES"
        docker-compose $COMPOSE_FILES up -d

        # Execution of the installation script inside the container
        echo "Running installation script inside the wemx container..."
        docker exec wemx /usr/local/bin/install.sh

        echo "Done!"
        ;;
    restart)
        echo "Restarting all Docker containers with configuration: $COMPOSE_FILES"
        docker-compose $COMPOSE_FILES restart

        # Execution of the installation script inside the container
        echo "Running installation script inside the wemx container..."
        docker exec wemx /usr/local/bin/install.sh

        echo "Done!"
        ;;
    rebuild)
        echo "Rebuilding Docker containers with configuration: $COMPOSE_FILES"
        docker-compose $COMPOSE_FILES down
        docker-compose $COMPOSE_FILES build
        docker-compose $COMPOSE_FILES up -d

        # Execution of the installation script inside the container
        echo "Running installation script inside the wemx container..."
        docker exec wemx /usr/local/bin/install.sh

        echo "Done!"
        ;;
    *)
        show_help
        ;;
esac
