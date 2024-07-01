FROM php:8.3-fpm

# Copy configuration files
COPY .docker/php/php.ini /usr/local/etc/php/
COPY .docker/php/docker.conf /usr/local/etc/php-fpm.d/docker.conf
COPY .docker/php/.bashrc /root/
COPY .docker/php/crontab /etc/cron.d/laravel-cron
COPY .docker/php/run-cron.sh /usr/local/bin/run-cron.sh
COPY .docker/php/wemx.sh /usr/local/bin/wemx.sh

# Installing the necessary PHP packages and extensions
RUN apt-get update \
  && apt-get install -y build-essential zlib1g-dev default-mysql-client curl gnupg procps git unzip libzip-dev libpq-dev \
  && docker-php-ext-install zip pdo_mysql pdo_pgsql pgsql \
  && apt-get install -y libicu-dev \
  && docker-php-ext-configure intl \
  && docker-php-ext-install intl \
  && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
  && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
  && docker-php-ext-install gd \
  && pecl install redis && docker-php-ext-enable redis \
  && pecl install pcov && docker-php-ext-enable pcov \
  && apt-get install -y nano htop

# Installing Node.js, npm, Yarn
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs \
  && npm install npm@latest -g \
  && npm install yarn -g

# Installing Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php composer-setup.php \
  && php -r "unlink('composer-setup.php');" \
  && mv composer.phar /usr/local/bin/composer

# Composer settings
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin
RUN composer config --global process-timeout 3600

# Install supercronic
ADD https://github.com/aptible/supercronic/releases/download/v0.1.12/supercronic-linux-amd64 /usr/local/bin/supercronic

# Setting access rights
RUN chmod 0644 /etc/cron.d/laravel-cron \
  && chmod +x /usr/local/bin/run-cron.sh \
  && chmod +x /usr/local/bin/wemx.sh \
  && chmod +x /usr/local/bin/supercronic

# Running supercronic and PHP-FPM
CMD [ "sh", "-c", "/usr/local/bin/supercronic /etc/cron.d/laravel-cron & php-fpm"]

EXPOSE 5173
WORKDIR /var/www
