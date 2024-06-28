#!/bin/bash
cd /var/www
php artisan schedule:run >> /var/www/storage/logs/cron.log 2>&1