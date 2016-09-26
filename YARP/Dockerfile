FROM ubuntu:xenial
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

RUN sh -c 'echo "deb http://www.icub.org/ubuntu xenial contrib/science" > /etc/apt/sources.list.d/icub.list' && \
    apt-get update && \
    apt-get install -y --allow-unauthenticated yarp && \
    apt-get clean && \
    dpkg-reconfigure locales && \
    locale-gen en_US.UTF-8 && \
    echo "Europe/Rome" > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get autoclean && \
    apt-get autoremove

RUN yarp check

EXPOSE 10000/tcp
