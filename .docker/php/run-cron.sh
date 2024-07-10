#!/bin/bash
# shellcheck disable=SC2164
cd /var/www || { echo "Error: Cannot change to working directory /var/www"; exit 1; }
php artisan schedule:run >> /var/www/storage/logs/cron.log 2>&1
chown -R www-data:www-data /var/www
chmod -R 777 /var/www
