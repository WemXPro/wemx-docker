#!/bin/bash
php artisan wemx:update ${LICENSE_KEY}
php artisan wemx:chown
php artisan storage:link --force
php artisan queue:start --force