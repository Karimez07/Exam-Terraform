#!/bin/bash
set -euxo pipefail


exec > >(tee /var/log/install-wordpress.log)
exec 2>&1

DB_NAME="wordpress_db"
DB_USER="liora-student"
DB_PASSWORD="Liora@2026"

WORDPRESS_DIR="/var/www/html" # wordpress code directory


# Update the system
yum update -y


# Install expect package
yum install expect -y


# Enable the PHP 8.2 repository provided by Amazon Linux Extras.
# By default, Amazon Linux 2 may install an older PHP version.
# Refresh the YUM metadata so the package manager can see the newly enabled repository.
PHP_REPO=$(amazon-linux-extras list | awk '/php8/ {print $1}' | tail -1)
amazon-linux-extras enable "$PHP_REPO"
yum clean metadata


# Install Apache HTTP server, required PHP modules and MariaDB
yum install -y \
httpd \
wget \
php \
php-bcmath \
php-curl \
php-fpm \
php-gd \
php-intl \
php-mbstring \
php-mysqlnd \
php-xml \
php-zip \
mariadb-server


# Start and enable Apache to start on boot
systemctl enable --now httpd


# Add user to apache group
usermod -aG apache ec2-user


# Create a PHP info page
chown -R ec2-user:apache /var/www/html/
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php


# Start and enable MariaDB to start on boot
systemctl enable --now mariadb


# Secure the MariaDB installation
echo "Securing MariaDB installation..."
expect - <<EOF
spawn mysql_secure_installation
expect "Enter current password for root (enter for none):"
send "\r"
expect "Switch to unix_socket authentication:"
send "n\r"
expect "Change the root password?"
send "y\r"
expect "New password:"
send "$DB_PASSWORD\r"
expect "Re-enter new password:"
send "$DB_PASSWORD\r"
expect "Remove anonymous users?"
send "y\r"
expect "Disallow root login remotely?"
send "y\r"
expect "Remove test database and access to it?"
send "y\r"
expect "Reload privilege tables now?"
send "y\r"
expect eof
EOF
echo "MariaDB installation secured."


# Change to the user's home directory
cd /home/ec2-user


# Download the latest WordPress
wget https://wordpress.org/latest.tar.gz -O wordpress.tar.gz


# Extract the WordPress archive
tar -xzf wordpress.tar.gz
rm wordpress.tar.gz


# Move WordPress files to Apache's web directory
cp -a wordpress/. $WORDPRESS_DIR
rm -r wordpress/


# Change ownership of the web directory
chown -R ec2-user:apache $WORDPRESS_DIR


# Create the WordPress database
mysql -u root -e "CREATE DATABASE $DB_NAME;"


# Create a user for the database
mysql -u root -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"


# Grant privileges to the user
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"


# Flush privileges
mysql -u root -e "FLUSH PRIVILEGES;"


# Change to the WordPress directory
cd $WORDPRESS_DIR


# Create a WordPress configuration file from the sample
cp wp-config-sample.php wp-config.php


# Replace database name in the configuration file
sed -i "s/database_name_here/$DB_NAME/" wp-config.php


# Replace database username in the configuration file
sed -i "s/username_here/$DB_USER/" wp-config.php


# Replace database password in the configuration file
sed -i "s/password_here/$DB_PASSWORD/" wp-config.php


# Replace database host in the configuration file
# Ligne qui ne sert à rien ici, mais à garder si on veut avoir une db sur un autre hôte
sed -i "s/localhost/localhost/" wp-config.php




# Set appropriate permissions for the web directory (directories)
find $WORDPRESS_DIR -type d -exec chmod 755 {} \;


# Set appropriate permissions for the web directory (files)
find $WORDPRESS_DIR -type f -exec chmod 644 {} \;


# Restart Apache
systemctl restart httpd


echo
echo "**************************************************************************************"
echo "******** Liora Wordpress installation has been executed successfully ********"
echo "**************************************************************************************"
echo
