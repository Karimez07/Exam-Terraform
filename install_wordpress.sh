#!/bin/bash
set -euo pipefail


exec > >(tee /var/log/install-wordpress.log)
exec 2>&1

DB_HOST="${db_host}"
DB_NAME="${db_name}"
DB_USER="${db_username}"
DB_PASSWORD="${db_password}"

WORDPRESS_DIR="/var/www/html" # wordpress code directory


# Update the system
dnf update -y

# Install Apache HTTP server, required PHP modules and MariaDB
 dnf install -y \
    httpd \
    wget \
    php \
    php-fpm \
    php-mysqlnd \
    php-mysqli \
    php-json

 # Wait until Terraform attaches the EBS volume
  EBS_DEVICE=""

  for attempt in $(seq 1 60); do
    for candidate in /dev/sdf /dev/xvdf; do
      if [ -b "$candidate" ]; then
        EBS_DEVICE="$candidate"
        break 2
      fi
    done

    sleep 5
  done

  if [ -z "$EBS_DEVICE" ]; then
    echo "Le volume EBS n'a pas été détecté."
    exit 1
  fi

  # Create a filesystem only when the volume is still empty
  if ! blkid "$EBS_DEVICE" >/dev/null 2>&1; then
    mkfs.ext4 "$EBS_DEVICE"
  fi

  mkdir -p "$WORDPRESS_DIR"

  EBS_UUID=$(blkid -s UUID -o value "$EBS_DEVICE")

  if ! grep -q "UUID=$EBS_UUID " /etc/fstab; then
    echo "UUID=$EBS_UUID $WORDPRESS_DIR ext4 defaults,nofail 0 2" >> /etc/fstab
  fi

  mountpoint -q "$WORDPRESS_DIR" || mount "$WORDPRESS_DIR"

# Start and enable Apache to start on boot
systemctl enable --now httpd


# Add user to apache group
usermod -aG apache ec2-user

chown -R ec2-user:apache /var/www/html/
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

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
sed -i "s/localhost/$DB_HOST/" wp-config.php




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
