#!/bin/bash

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# set env
glpi_user_glpi_password=${GLPI_USER_GLPI_PASSWORD:-password}
glpi_user_post_password=${GLPI_USER_POST_PASSWORD:-password}
glpi_user_tech_password=${GLPI_USER_TECH_PASSWORD:-password}
glpi_user_normal_password=${GLPI_USER_NORMAL_PASSWORD:-password}

cd /var/www/html

echo "Checking if MariaDB is ready..."

while ! mysqladmin ping -h "$GLPI_DB_HOST" --silent; do
  echo "MariaDB is unavailable - sleeping"
  sleep 5
done

echo "MariaDB is up - continuing with GLPI setup"

php bin/console system:check_requirements

php bin/console db:install -n -r \
    -H $GLPI_DB_HOST -P $GLPI_DB_PORT \
    -d $GLPI_DB_NAME -u $GLPI_DB_USER -p $GLPI_DB_PASSWORD

php bin/console db:configure -n -r -H $GLPI_DB_HOST -P $GLPI_DB_PORT \
  -d $GLPI_DB_NAME -u $GLPI_DB_USER -p $GLPI_DB_PASSWORD

chown -R www-data:www-data /var/www/html/files
chown -R www-data:www-data /var/www/html/config
chmod -R 775 /var/www/html/files
chmod -R 775 /var/www/html/config

rm install/install.php

php bin/console config:set --context=inventory enabled_inventory 1

echo "Update password..."
update_password() {
  mariadb -h mariadb -u $GLPI_DB_USER --password=$GLPI_DB_PASSWORD $GLPI_DB_NAME \
    --execute="UPDATE glpi_users SET password = SHA1( '$2' ) WHERE name='$1';"

}

update_password glpi      "${glpi_user_glpi_password}"
update_password post-only "${glpi_user_post_password}"
update_password tech      "${glpi_user_tech_password}"
update_password normal    "${glpi_user_normal_password}"

echo "Launch apache..."
exec apache2-foreground
