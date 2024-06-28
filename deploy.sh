#!/bin/bash

# Function to show help
show_help() {
    echo "Usage: ./deploy.sh [options]"
    echo ""
    echo "Options:"
    echo "  --force-delete       Force delete the .docker/db/data directory and APP_DIR without prompting"
    echo "  -h, --help           Show this help message and exit"
}

# Argument parsing
FORCE_DELETE=false

for arg in "$@"; do
    case $arg in
    --force-delete)
        FORCE_DELETE=true
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

# Restart Docker Compose
docker-compose down
docker-compose build
docker-compose up -d

echo "Waiting for the database to start..."

# Checking the state of the database container
while ! docker-compose exec db mysqladmin --user=${DB_USERNAME} --password=${DB_PASSWORD} --host ${DB_HOST} ping --silent &> /dev/null; do
    echo "Waiting for the database connection..."
    sleep 5
done

# Execution of the installation script inside the container
echo "Running installation script inside the php container..."
docker exec php /usr/local/bin/install.sh

# Restarting docker-compose
docker-compose down
docker-compose up -d

echo "Done!"
