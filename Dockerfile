FROM whooshkaa/docker-php:latest
MAINTAINER Seongmin Park "wluns32@gmail.com"

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
RUN mkdir /var/run/sshd
RUN mkdir /run/php

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y install software-properties-common
RUN add-apt-repository -y 'deb http://archive.ubuntu.com/ubuntu trusty universe'

# Install MySQL 5.6 and SSH
RUN apt-get update && apt-get install -y mysql-client-5.6 mysql-server-5.6 openssh-server openssl htop sudo nano git python-setuptools

# Supervisor Config
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
ADD ./supervisord.conf /etc/supervisord.conf

# MySQL setting
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# Create 'wordpress' user
RUN useradd -m -d /home/wordpress -p $(openssl passwd -1 'wordpress') -G root -s /bin/bash wordpress \
    && usermod -a -G www-data wordpress \
    && usermod -a -G sudo wordpress \
    && ln -s /var/www/html /home/wordpress/html

# Install Wordpress
ADD http://wordpress.org/latest.tar.gz /var/www/html/latest.tar.gz
RUN cd /var/www/html/ \
    && tar xvf latest.tar.gz \
    && rm latest.tar.gz

RUN mv /var/www/html/wordpress /var/www/html/wp \
    && chown -R wordpress:www-data /var/www/html/wp \
    && chmod -R 775 /var/www/html/wp

# Install phpmyadmin
ADD https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz /usr/share/phpmyadmin.tar.gz
RUN cd /usr/share/ \
    && tar xvf phpmyadmin.tar.gz \
    && rm phpmyadmin.tar.gz \
    && mv phpMyAdmin* phpmyadmin \
    && cd /usr/share/phpmyadmin/ \
    && rm -rf setup/ examples/ test/ composer.json \
    && cp config.sample.inc.php config.inc.php \
    && ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
RUN sed -i "s|\['blowfish_secret'\] = ''|\['blowfish_secret'\] = 'eB#]aa+fGm%zjB1S=TL4Q$%J%I8GiBw4AO4E1SHCek8'|g" /var/www/html/phpmyadmin/config.inc.php

# Add phpinfo()
RUN echo "<?php phpinfo();" >> /var/www/html/phpinfo.php

ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

ADD .htaccess /var/www/html/.htaccess

EXPOSE 9011
EXPOSE 3306
EXPOSE 80
EXPOSE 22

CMD ["/bin/bash", "/start.sh"]