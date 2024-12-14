#
# - node for npm build
# - composer for php dependencies
# - prod for final image
# - dev based on prod, with custom options
#

# node.js and npm
FROM debian:12.8-slim AS node

ENV DEBIAN_FRONTEND=noninteractive

# updating and installing required components
RUN apt update \
 && apt install --no-install-recommends -y curl ca-certificates gpg \
#
# installing nodejs repository
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
#
# updating
 && apt update \
#
# installing nodejs & npm
 && apt-get install -y nodejs

WORKDIR /app
COPY . .

# installing dependencies
RUN npm install \
#
# building
 && npm run build

# php and composer
FROM debian:12.8-slim AS php

ENV DEBIAN_FRONTEND=noninteractive \
    COMPOSER_ALLOW_SUPERUSER=1 \
    APP_ENV=ci

# updating and installing required components
RUN apt update \
 && apt install --no-install-recommends -y software-properties-common curl gnupg zip unzip p7zip-full git \
#
# installing php repository
 && echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/php.list \
 && curl -L https://packages.sury.org/php/apt.gpg | apt-key add - \
#
# updating and upgrading system
 && apt update \
#
# installing php
 && apt install --no-install-recommends -y php8.3 php8.3-curl php8.3-xml php8.3-amqp php8.3-zip \
#
# installing composer
 && curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin \
 && chmod +x /usr/local/bin/composer

WORKDIR /app
COPY . .

# installing dependencies
RUN composer install --prefer-dist --optimize-autoloader --no-interaction

# base image for everything
FROM debian:12.8-slim AS prod

ARG VERSION=latest

ENV DEBIAN_FRONTEND=noninteractive \
    COMPOSER_ALLOW_SUPERUSER=1 \
    APP_ENV=prod \
    PATH="/app/bin:${PATH}" \
    PHP_INI_DIR="/etc/php/8.3" \
    S6_OVERLAY_VERSION=3.1.6.2 \
    CADDY_VERSION=2.8.4 \
    VERSION=${VERSION}

# updating and installing required components
RUN apt update \
 && apt install --no-install-recommends -y software-properties-common curl gnupg zip unzip p7zip-full libvips42 git xz-utils sudo htop micro jq \
#
# installing php repository
 && echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/php.list \
 && curl -L https://packages.sury.org/php/apt.gpg | apt-key add - \
#
# updating
 && apt update \
#
# installing php
 && apt install --no-install-recommends -y php8.3 php8.3-fpm php8.3-curl php8.3-xml php8.3-amqp php8.3-zip php8.3-intl php8.3-mysql php8.3-redis \
#
# configuring php
 && sed -i 's/memory_limit =/#memory_limit =/' ${PHP_INI_DIR}/fpm/php.ini \
 && echo 'memory_limit = 512M' | tee -a $PHP_INI_DIR/cli/php.ini $PHP_INI_DIR/fpm/php.ini \
 && echo 'opcache.preload=/app/config/preload.php' | tee -a $PHP_INI_DIR/fpm/php.ini \
#
# installing caddy (via github)
 && curl -sL -o /tmp/caddy.deb https://github.com/caddyserver/caddy/releases/download/v${CADDY_VERSION}/caddy_${CADDY_VERSION}_linux_$([ $(uname -m) = 'aarch64' ] && echo 'arm64' || echo 'amd64').deb \
 && dpkg -i /tmp/caddy.deb \
 && rm /tmp/caddy.deb \
#
# cleaning up
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
#
# installing s6
 && curl -sL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz | tar -C / -Jxpf - \
 && curl -sL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-$([ $(uname -m) = 'aarch64' ] && echo 'aarch64' || echo 'x86_64').tar.xz | tar -C / -Jxpf - \
#
# correcting permissions
 && adduser caddy sudo \
 && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


USER caddy
WORKDIR /app
COPY --chown=caddy . .
#COPY --chown=caddy --from=node /app/public/assets /app/public/assets
#COPY --chown=caddy --from=php /app/vendor /app/vendor
COPY --chown=caddy .docker/rootfs /
RUN chmod +x /*.sh

HEALTHCHECK --start-period=5s --interval=10s --timeout=5s --retries=3 CMD ["/healthcheck.sh"]
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 80

# dev image
FROM prod AS dev

ENV DEBIAN_FRONTEND=noninteractive \
    COMPOSER_ALLOW_SUPERUSER=1 \
    APP_ENV=dev \
    PATH="/app/bin:${PATH}" \
    PHP_INI_DIR="/etc/php/8.3" \
    VERSION="dev"

USER root

# updating and installing required components
RUN apt update \
 && apt install --no-install-recommends -y libzip-dev build-essential \
#
# installing nodejs repository
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
#
# installing symfony repository
 && curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash \
#
# updating
 && apt update \
#
# install symfony & php
 && apt install --no-install-recommends -y symfony-cli php8.3-mbstring php8.3-xdebug php8.3-dev \
#
# installing xdebug for php
 && rm -f $PHP_INI_DIR/mods-available/xdebug.ini && touch $PHP_INI_DIR/mods-available/xdebug.ini \
 && echo "zend_extension=xdebug.so" >> $PHP_INI_DIR/mods-available/xdebug.ini \
 && echo "xdebug.start_with_request=yes" >> $PHP_INI_DIR/mods-available/xdebug.ini \
 && echo "xdebug.discover_client_host=yes" >> $PHP_INI_DIR/mods-available/xdebug.ini \
 && echo "xdebug.mode=develop,coverage,debug" >> $PHP_INI_DIR/mods-available/xdebug.ini  \
# && echo "xdebug.idekey=SIMONPRINZ_ACCOUNTABLE" >> $PHP_INI_DIR/mods-available/xdebug.ini  \
 && echo "xdebug.client_host=host.docker.internal" >> $PHP_INI_DIR/mods-available/xdebug.ini \
 && echo "xdebug.client_port = 9003" >> $PHP_INI_DIR/mods-available/xdebug.ini \
#
# installing spx for php
 && git clone https://github.com/NoiseByNorthwest/php-spx.git php-spx && cd php-spx \
 && git checkout release/latest \
 && phpize && ./configure && make && make install \
 && cd .. && rm -rf php-spx \
 && echo 'extension=spx.so' | tee -a $PHP_INI_DIR/cli/php.ini $PHP_INI_DIR/fpm/php.ini \
 && echo 'spx.http_enabled=1' | tee -a $PHP_INI_DIR/cli/php.ini $PHP_INI_DIR/fpm/php.ini \
 && echo 'spx.http_key="dev"' | tee -a $PHP_INI_DIR/cli/php.ini $PHP_INI_DIR/fpm/php.ini \
 && echo 'spx.http_ip_whitelist="*"' | tee -a $PHP_INI_DIR/cli/php.ini $PHP_INI_DIR/fpm/php.ini \
#
# installing composer
 && curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin \
 && chmod +x /usr/local/bin/composer \
#
# installing nodejs & npm
 && apt install --no-install-recommends -y nodejs \
#
# cleaning up
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

USER caddy
