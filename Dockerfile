# PHP base image với Apache
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

# Bật module rewrite và headers của Apache
RUN a2enmod rewrite headers

# Cấu hình Apache phục vụ Laravel đúng cách với AllowOverride All
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/public\n\
    <Directory /var/www/public>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Kích hoạt site mới và vô hiệu site mặc định nếu cần
RUN a2dissite 000-default && a2ensite 000-default

# Copy Composer từ official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy toàn bộ mã nguồn Laravel vào container
COPY . /var/www

# Đặt thư mục làm việc mặc định
WORKDIR /var/www

# Cài đặt Composer dependencies, bỏ phần dev và tối ưu autoloader
RUN composer install --optimize-autoloader --no-dev

# Cấp quyền ghi cho storage và bootstrap/cache (bắt buộc với Laravel)
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Tạo file .env từ .env.example và generate APP_KEY, cache config & routes
RUN cp .env.example .env && \
    php artisan key:generate && \
    php artisan config:cache && \
    php artisan route:cache

# Expose cổng 80 để truy cập HTTP
EXPOSE 80

# Khởi động Apache khi container chạy
CMD ["apache2-foreground"]
