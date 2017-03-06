FROM ubuntu:xenial
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

RUN echo "deb http://www.icub.org/ubuntu xenial contrib/science" \
        > /etc/apt/sources.list.d/icub.list &&\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 57A5ACB6110576A6 &&\
    apt-get update &&\
    apt-get install -y \
        yarp \
        icub &&\
    rm -rf /var/lib/apt/lists/*

RUN yarp check
EXPOSE 10000/tcp

# Some QT-Apps/Gazebo don't show controls without this
ENV QT_X11_NO_MITSHM 1

# Required by gazebo-yarp-plugins
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable xenial main" \
        > /etc/apt/sources.list.d/gazebo-stable.list &&\
    wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - &&\
	 apt-get update &&\
    apt-get install -y --no-install-recommends \
        gazebo8 \
        gazebo8-plugin-base \
        libgazebo8-dev &&\
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
