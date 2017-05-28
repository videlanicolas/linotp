FROM ubuntu:precise

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'deb http://www.linotp.org/apt/debian wheezy linotp' > /etc/apt/sources.list.d/linotp.list &&\
	apt-key adv --keyserver eu.pool.sks-keyservers.net --recv-keys 913DFF12F86258E5

RUN apt-get update &&\
	apt-get install --no-upgrade -y --no-install-recommends python-pip software-properties-common python-software-properties libdigest-hmac-perl freeradius linotp-freeradius-perl curl &&\
	pip install boto3

RUN add-apt-repository ppa:linotp/stable &&\
	apt-get update &&\
	apt-get install --no-upgrade -y --no-install-recommends linotp

RUN echo "DEFAULT Auth-type := perl" > /etc/freeradius/users &&\
	echo "perl {module = /usr/lib/linotp/radius_linotp.pm}" > /etc/freeradius/modules/perl

COPY rlm_perl.ini /etc/linotp2/rlm_perl.ini
COPY clients.conf /etc/freeradius/clients.conf
COPY linotp_freeradius /etc/freeradius/sites-available/linotp

RUN ln -s /etc/freeradius/sites-available/linotp /etc/freeradius/sites-enabled &&\
	rm -f /etc/apache2/sites-enabled/000-default

COPY s3download.py /bin/s3download
COPY bootstrap.sh /bin/bootstrap

ENTRYPOINT bootstrap
