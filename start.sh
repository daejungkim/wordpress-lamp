#!/bin/sh
if [ ! -f /wordpress-db-pw.txt ]; then
    /usr/bin/mysqld_safe &
    sleep 10s
    MYSQL_PASSWORD="root"
    WORDPRESS_PASSWORD="root"
    
    mysqladmin -u root password $MYSQL_PASSWORD
    mysql -uroot -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
    mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY '$WORDPRESS_PASSWORD'; FLUSH PRIVILEGES;"
    killall mysqld
fi

if [ ! -f /var/www/html/wp/wp-config.php ]; then
   WORDPRESS_DB="wordpress"
   WORDPRESS_PASSWORD=`cat /wordpress-db-pw.txt`
   sed -e "s/database_name_here/$WORDPRESS_DB/
   s/username_here/$WORDPRESS_DB/
   s/password_here/$WORDPRESS_PASSWORD/
   /'AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
   /'SECURE_AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
   /'LOGGED_IN_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
   /'NONCE_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
   /'AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
   /'SECURE_AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
   /'LOGGED_IN_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
   /'NONCE_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/" /var/www/html/wp/wp-config-sample.php > /var/www/html/wp/wp-config.php

   chown -R wordpress: /var/www/html/
fi

 /usr/local/bin/supervisord -n -c /etc/supervisord.conf