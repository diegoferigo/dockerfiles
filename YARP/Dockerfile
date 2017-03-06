FROM robotology/yarp:gazebo8bin
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

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
