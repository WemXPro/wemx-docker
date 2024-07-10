#!/bin/bash

# Function to add variables to the .env file
add_env_variable() {
    local key=$1
    local value=$2
    if grep -q "^${key}=" /var/www/.env; then
        echo "Updating existing environment variable: ${key}"
        sed -i "s/^${key}=.*/${key}=${value}/" /var/www/.env
    else
        echo "Adding new environment variable: ${key}"
        echo "${key}=${value}" >> /var/www/.env
    fi
}

# Check if Laravel project exists
if [ -z "$(ls -A /var/www)" ]; then
    echo "Cloning Laravel project..."
    git clone https://github.com/laravel/laravel.git /var/www
else
    echo "Laravel project already exists. Skipping git clone."
fi

# Check for necessary dependencies
if [ ! -d "/var/www/vendor" ] || [ ! -f "/var/www/vendor/autoload.php" ]; then
    echo "Running necessary composer and artisan commands..."
    cd /var/www
    rm database/migrations/* -r
    composer require wemx/installer dev-web -n
    php artisan wemx:install ${LICENSE_KEY} --type=${TYPE} --ver=${VERSION}
    yes | cp -f .env.example .env
    yes | composer install --optimize-autoloader -n
    yes | composer update -n
    php artisan key:generate --force
    php artisan setup:database --host=${DB_HOST} --port=${DB_PORT} --database=${DB_DATABASE} --username=${DB_USERNAME} --password=${DB_PASSWORD} --no-interaction

    add_env_variable "APP_URL" ${APP_URL}
    add_env_variable "FORCE_HTTPS" ${FORCE_HTTPS}
    add_env_variable "LARAVEL_CLOUDFLARE_ENABLED" ${LARAVEL_CLOUDFLARE_ENABLED}

    php artisan module:enable
    php artisan storage:link
    php artisan migrate --force --no-interaction
    php artisan license:update ${LICENSE_KEY}
    php artisan user:create --email=${EMAIL} --password=${PASSWORD} --username=${USERNAME} --first_name=${FIRST_NAME} --last_name=${LAST_NAME} --no-interaction
    php artisan wemx:chown
    php artisan storage:link
    php artisan queue:start --force
else
    echo "Dependencies are already installed. Skipping composer and artisan commands."
    php artisan wemx:chown
    php artisan storage:link --force
    php artisan migrate --force --no-interaction
    php artisan queue:start --force
fi


