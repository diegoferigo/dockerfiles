FROM ubuntu:xenial
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

RUN sh -c 'echo "deb http://www.icub.org/ubuntu xenial contrib/science" > /etc/apt/sources.list.d/icub.list' &&\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 57A5ACB6110576A6 &&\
    apt-get update &&\
    apt-get install -y \
        yarp \
        icub &&\
    rm -rf /var/lib/apt/lists/* &&\
    dpkg-reconfigure locales &&\
    locale-gen en_US.UTF-8 &&\
    echo "Europe/Rome" > /etc/timezone &&\
    dpkg-reconfigure --frontend noninteractive tzdata &&\
    apt-get autoclean &&\
    apt-get autoremove

RUN yarp check
EXPOSE 10000/tcp

# Some QT-Apps/Gazebo don't show controls without this
ENV QT_X11_NO_MITSHM 1

# Required by gazebo-yarp-plugins
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116 &&\
    echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends \
        gazebo7 \
        gazebo7-plugin-base \
        libgazebo7-dev &&\
    rm -rf /var/lib/apt/lists/*

# Setup HW Acceleration for Intel graphic cards
RUN apt-get update && apt-get install -y \
        libgl1-mesa-glx \
        libgl1-mesa-dri &&\
    rm -rf /var/lib/apt/lists/*

# Additional tools
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        cmake-curses-gui &&\
    rm -rf /var/lib/apt/lists/*

# Setup an additional entrypoint script
# For the time being it only creates a new runtime user
COPY entrypoint.sh /usr/sbin/entrypoint.sh
RUN chmod 755 /usr/sbin/entrypoint.sh
ENTRYPOINT ["/usr/sbin/entrypoint.sh"]
CMD ["bash"]
