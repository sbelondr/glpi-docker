# Base image avec PHP et Apache
FROM php:8.3-apache

ENV VERSION=10.0.17

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libbz2-dev \
    libzip-dev \
    libldap2-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zlib1g-dev \
    libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
    curl \
    bz2 \
    zip \
    exif \
    intl \
    mysqli \
    gd \
    ldap \
    opcache \
    && docker-php-ext-enable \
    opcache

RUN apt-get install -y mariadb-client

WORKDIR /var/www/html

RUN curl -o glpi.tgz -SL https://github.com/glpi-project/glpi/releases/download/${VERSION}/glpi-${VERSION}.tgz \
    && tar -xzf glpi.tgz --strip-components=1 \
    && rm glpi.tgz

COPY php.ini /usr/local/etc/php/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

RUN a2enmod rewrite
COPY ./glpi-apache.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]