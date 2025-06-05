# Sử dụng PHP 8.1 với Apache
FROM php:8.1-apache

# Cài các extension và package cần thiết
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Cài Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy toàn bộ mã nguồn vào container
COPY . /var/www/html

# Laravel yêu cầu quyền ghi cho storage và bootstrap/cache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Bật rewrite module cho Apache
RUN a2enmod rewrite

# Chỉ định thư mục làm việc
WORKDIR /var/www/html

EXPOSE 80
