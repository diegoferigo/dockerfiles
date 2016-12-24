FROM ros:kinetic
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

# Install ROS Desktop
RUN apt-get update && apt-get install -y \
        ros-kinetic-desktop-full \
        ros-kinetic-fake-localization \
        ros-kinetic-map-server &&\
    rm -rf /var/lib/apt/lists/*

# Other useful packages
RUN apt-get update && apt-get install -y \
        nano \
        tree \
        gdb \
        valgrind \
        locales &&\
    rm -rf /var/lib/apt/lists/* &&\
    dpkg-reconfigure locales &&\
    locale-gen en_US.UTF-8 &&\
    echo "Europe/Rome" > /etc/timezone &&\
    dpkg-reconfigure --frontend noninteractive tzdata &&\
    apt-get autoclean &&\
    apt-get autoremove

# Setup the environment
RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc

# Some QT-Apps/Gazebo don't show controls without this
ENV QT_X11_NO_MITSHM 1
