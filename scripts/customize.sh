#!/usr/bin/env bash

DIRECTORY="/etc/nginx/sites-available/
/etc/nginx/sites-enabled/
/etc/mysql/conf.d/"

PHP_DIR="/vagrant/php/*"
NGINX_DIR="/vagrant/nginx/*"
MYSQL_DIR="/vagrant/mysql/*"

REMOVE_FILES="/etc/nginx/site-enabled/default
/etc/nginx/conf.d/default.conf
/etc/nginx/conf.d/example_ssl.conf"

echo "Creating directory";
for d in ${DIRECTORY}
do
    if [ ! -d "$d" ]; then
        echo "Processing $d directory..."
        mkdir ${d}
    fi
done

echo "Remove files";
for f in ${REMOVE_FILES}
do
    if [ -e "$f" ]; then
        echo "Processing $f file..."
        rm -f ${f}
    fi
done

# Php config
echo "Config php";

echo "Copy files";
for f in ${PHP_DIR}
do
  echo "Processing $f file..."
  cp ${f} /etc/php56/
done

if ! php -v | grep "PHP 5.6"; then
    echo "Change php to 5.6";
    newphp 56
fi

echo "Restart service";
service php-fpm restart > /dev/null

# Nginx config
echo "Config nginx";

echo "include /etc/nginx/sites-enabled/*;" > /etc/nginx/conf.d/sites.conf;

echo "Copy files";
for f in ${NGINX_DIR}
do
  echo "Processing $f file..."
  cp ${f} /etc/nginx/sites-available/
done

echo "Creating symbolic links";
for f in '/etc/nginx/sites-available/*'
do
    echo "Processing $f file..."
    ln -fs ${f} /etc/nginx/sites-enabled/ > /dev/null
done

echo "RestApi Nginx fastcgi_params";
if ! grep "fastcgi_param PATH_INFO \$fastcgi_script_name;" /etc/nginx/fastcgi_params; then
    echo -e "\n\n# RestApi PATH_INFO" >> /etc/nginx/fastcgi_params;
    echo -e "\nfastcgi_param PATH_INFO \$fastcgi_script_name;\n" >> /etc/nginx/fastcgi_params
fi

echo "Restart service";
service nginx restart > /dev/null

# Mysql config
echo "Config mysql";
for f in ${MYSQL_DIR}
do
  echo "Processing $f file..."
  cp ${f} /etc/mysql/conf.d/
done

echo "Restart service";
service mysql restart > /dev/null

# Apache
echo "Disable apache";
service apache2 stop > /dev/null
