FROM ubuntu:24.04 
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y apache2 \
                       ghostscript \
                       libapache2-mod-php \
                       php \
                       php-bcmath \
                       php-curl \
                       php-imagick \
                       php-intl \
                       php-json \
                       php-mbstring \
                       php-mysql \
                       php-xml \
                       php-zip \
                       curl \
                       openssl
RUN mkdir -p /srv/www && chown www-data: /srv/www
RUN curl -fL https://wordpress.org/latest.tar.gz | runuser -u www-data -- tar -xzf - -C /srv/www
WORKDIR /etc/apache2/sites-available
COPY ./wordpress.conf .
RUN a2ensite wordpress
RUN a2enmod rewrite
RUN a2dissite 000-default
COPY ./wordpress-docker.sh /usr/local/bin/wordpress-docker.sh
RUN sed -i 's/\r$//' /usr/local/bin/wordpress-docker.sh \
 && chmod +x /usr/local/bin/wordpress-docker.sh
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
EXPOSE 80
CMD ["/usr/local/bin/wordpress-docker.sh"]