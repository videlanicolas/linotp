FROM ubuntu:trusty

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'deb http://www.linotp.org/apt/debian wheezy linotp' > /etc/apt/sources.list.d/linotp.list &&\
	apt-key adv --keyserver eu.pool.sks-keyservers.net --recv-keys 913DFF12F86258E5

RUN apt-get update &&\
	apt-get install --no-upgrade -y --no-install-recommends python-pip software-properties-common python-software-properties libdigest-hmac-perl linotp-freeradius-perl curl &&\
	apt-get install freeradius freeradius-common &&\
	pip install boto3

RUN add-apt-repository ppa:linotp/stable &&\
	apt-get update &&\
	apt-get install --no-upgrade -y --no-install-recommends linotp

RUN echo "perl {\nmodule = /usr/lib/linotp/radius_linotp.pm \n}" > /etc/freeradius/modules/perl

COPY users_radius /etc/freeradius/users
COPY rlm_perl.ini /etc/linotp2/rlm_perl.ini
COPY clients.conf /etc/freeradius/clients.conf
COPY linotp_freeradius /etc/freeradius/sites-available/linotp
COPY apache.conf /etc/apache2/sites-available/linotp2

RUN ln -s /etc/freeradius/sites-available/linotp /etc/freeradius/sites-enabled &&\
	rm -f /etc/apache2/sites-enabled/000-default

COPY s3download.py /bin/s3download
COPY bootstrap.sh /bin/bootstrap
COPY apacheconfig.py /bin/apacheconfig

RUN chmod +x /bin/apacheconfig
RUN a2enmod ldap authnz_ldap

RUN chown linotp /etc/linotp2/linotpapp.wsgi
RUN chmod 400 /etc/linotp2/linotpapp.wsgi

RUN chown linotp /etc/linotp2/linotp.ini
RUN chmod 400 /etc/linotp2/linotp.ini

RUN chown linotp /etc/linotp2/private.pem
RUN chmod 400 /etc/linotp2/private.pem

ENTRYPOINT bootstrap
