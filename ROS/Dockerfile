FROM ros:kinetic
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

# Install ROS Desktop and other useful packages
RUN apt-get update
RUN apt-get install -y ros-kinetic-desktop nano tree

# Setup the environment
RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc

# Some QT-Apps/Gazebo don't not show controls without this
ENV QT_X11_NO_MITSHM 1
