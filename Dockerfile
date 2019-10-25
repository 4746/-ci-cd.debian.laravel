FROM debian:8.11

ARG DEBIAN_FRONTEND=noninteractive

ONBUILD ARG _UID
ONBUILD ARG _GID

ONBUILD RUN groupmod -g $_GID www-data \
 && usermod -u $_UID -g $_GID -s /bin/bash www-data \
 && echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

WORKDIR /root

RUN mkdir -p /var/www/ \
 && mkdir -p /var/run/php/ \
 && mkdir -p /var/log/php/ \
 && mkdir -p /var/run/mysqld/ \
 && mkfifo /var/run/mysqld/mysqld.sock

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    apt-utils dialog sudo automake bash-completion ca-certificates gnupg2 bzip2 net-tools ssh-client \
    dirmngr gcc g++ make rsync chrpath curl wget git vim nano unzip htop cron mc libaio1 \
    software-properties-common libmcrypt-dev \
 # PHP 7.3 Extensions
 && apt-get install -y -q lsb-release apt-transport-https \
 && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
 && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php7.3.list \
 && apt-get update && apt-get install -y \
    php7.3-common \
    php7.3-mysql \
    php7.3-xml \
    php7.3-xmlrpc \
    php7.3-curl \
    php7.3-gd \
    php7.3-imagick \
    php7.3-cli \
    php7.3-dev \
    php7.3-imap \
    php7.3-mbstring \
    php7.3-opcache \
    php7.3-soap \
    php7.3-zip \
    php7.3-intl \
 # Composer
 && cd /root \
 && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
 && php -r "unlink('composer-setup.php');" \
 # NodeJs LTS Release
 && curl -sL https://deb.nodesource.com/setup_10.x | sudo bash \
 && apt-get install nodejs \
 # Clean
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Setup working directory
WORKDIR /var/www
