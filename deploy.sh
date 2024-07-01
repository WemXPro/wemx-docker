#!/bin/bash

# Function to show help
show_help() {
    echo "Usage: ./deploy.sh [options]"
    echo ""
    echo "Options:"
    echo "  --force-delete       Force delete the .docker/db/data directory and APP_DIR without prompting"
    echo "  --down               Stop all Wemx Docker containers"
    echo "  --up                 Start all Wemx Docker containers"
    echo "  -h, --help           Show this help message and exit"
}

# Argument parsing
FORCE_DELETE=false
ACTION=""

for arg in "$@"; do
    case $arg in
    --force-delete)
        FORCE_DELETE=true
        shift
        ;;
    --down)
        ACTION="down"
        shift
        ;;
    --up)
        ACTION="up"
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

# Delete the .docker/db/data directory if the --force-delete option is passed
if [ "$FORCE_DELETE" = true ]; then
    if [ -d ".docker/db/data" ]; then
        echo "Force deleting .docker/db/data..."
        rm -rf .docker/db/data
    fi

    # Delete the directory named APP_DIR if the --force-delete parameter is passed
    if [ -d "./$APP_DIR" ]; then
        echo "Force deleting ./$APP_DIR..."
        rm -rf ./$APP_DIR
    fi
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
