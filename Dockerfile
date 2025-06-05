# PHP base image with Apache
FROM php:8.1-apache

# Cài các thư viện cần thiết cho Laravel
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    git \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Cài Composer từ official composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy toàn bộ mã nguồn Laravel vào container
COPY . /var/www/html

# Thiết lập quyền
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Bật module rewrite của Apache để Laravel hoạt động
RUN a2enmod rewrite

# Đặt thư mục làm việc mặc định
WORKDIR /var/www/html

# Cài đặt Composer và optimize project
RUN composer install --optimize-autoloader --no-dev

# Tạo APP_KEY và cache config
RUN php artisan key:generate \
    && php artisan config:cache \
    && php artisan route:cache

# Nếu có migration, bỏ comment dòng dưới (chỉ dùng khi chắc chắn đã có DB kết nối)
# RUN php artisan migrate --force

# Expose cổng 80 để Render có thể truy cập
EXPOSE 80
