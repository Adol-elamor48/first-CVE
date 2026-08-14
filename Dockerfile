FROM httpd:2.4.49

RUN sed -i '0,/Require all denied/s//Require all granted/' /usr/local/apache2/conf/httpd.conf

EXPOSE 80