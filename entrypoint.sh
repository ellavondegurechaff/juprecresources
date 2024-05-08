#!/bin/bash

set -e

# Run the build commands from the Containerfile
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    wget \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev \
    libpq-dev \
    libffi-dev \
    liblcms2-dev \
    libldap2-dev \
    libmariadb-dev \
    libsasl2-dev \
    libtiff5-dev \
    libwebp-dev \
    redis-tools \
    rlwrap \
    tk8.6-dev \
    cron \
    gcc \
    build-essential \
    libbz2-dev
rm -rf /var/lib/apt/lists/*

# Run the start command
exec "$@"