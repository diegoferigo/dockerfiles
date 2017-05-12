FROM diegoferigo/tools
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

# Install ROS Desktop Full
# https://github.com/osrf/docker_images/blob/master/ros/kinetic/kinetic-ros-core/Dockerfile
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net \
        --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116
RUN echo "deb http://packages.ros.org/ros/ubuntu xenial main" \
        > /etc/apt/sources.list.d/ros-latest.list
RUN apt-get update &&\
    apt-get install --no-install-recommends -y \
        python-rosdep \
        python-rosinstall \
        python-vcstools &&\
    rm -rf /var/lib/apt/lists/*
RUN rosdep init &&\
    rosdep update
ENV ROS_DISTRO kinetic
RUN apt-get update &&\
    apt-get install -y \
        ros-kinetic-desktop-full \
        ros-kinetic-fake-localization \
        ros-kinetic-map-server &&\
    rm -rf /var/lib/apt/lists/*

# Install libraries
RUN apt-get update &&\
    apt-get install -y \
        libeigen3-dev \
        libgsl-dev \
        libedit-dev \
        libace-dev &&\
    rm -rf /var/lib/apt/lists/*

# Install YARP, iCub and friends from sources
ENV IIT_DIR=/iit
ENV IIT_INSTALL=${IIT_DIR}/local
ENV IIT_SOURCES=${IIT_DIR}/sources
ARG IIT_BIN=${IIT_INSTALL}/bin
ENV IIT_PATH=${IIT_PATH:+${IIT_PATH}:}${IIT_BIN}
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${IIT_INSTALL}/lib/
ENV PATH=${IIT_PATH}:${PATH}

RUN mkdir -p ${IIT_SOURCES} ${IIT_BIN}

# Use cache for steps above
ARG IIT_DOCKER_SOURCES="11/05/2017"

# Build Variables
ARG SOURCES_BUILD_TYPE=Debug

# Download all sources with git
RUN cd ${IIT_SOURCES} &&\
    git clone https://github.com/robotology/yarp.git &&\
    git clone https://github.com/robotology/icub-main.git &&\
    git clone https://github.com/robotology/icub-contrib-common.git &&\
    git clone https://github.com/robotology/robot-testing.git &&\
    git clone https://github.com/robotology/ycm.git &&\
    git clone https://github.com/robotology/gazebo-yarp-plugins.git &&\
    git clone https://github.com/robotology/codyco-superbuild.git

# Concurrent compilation jobs
ENV GCC_JOBS=4

# Build all sources
RUN cd ${IIT_SOURCES}/yarp &&\
    mkdir build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          -DCREATE_GUIS=ON \
          -DCREATE_LIB_MATH=ON \
          .. &&\
    make -j ${GCC_JOBS} install &&\
    ln -s ${IIT_SOURCES}/yarp/scripts/yarp_completion \
          /etc/bash_completion.d/yarp_completion
ENV YARP_DIR=${IIT_INSTALL}
ENV YARP_DATA_DIRS=${IIT_INSTALL}/share/yarp
ENV YARP_COLORED_OUTPUT=1
RUN yarp check
EXPOSE 10000/tcp

RUN cd ${IIT_SOURCES}/icub-main &&\
    mkdir build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          -DENABLE_icubmod_cartesiancontrollerserver=ON \
          -DENABLE_icubmod_cartesiancontrollerclient=ON \
          -DENABLE_icubmod_gazecontrollerclient=ON \
          .. &&\
    make -j ${GCC_JOBS} install
ENV YARP_DATA_DIRS=${YARP_DATA_DIRS:+${YARP_DATA_DIRS}:}${IIT_INSTALL}/share/iCub

RUN cd ${IIT_SOURCES}/icub-contrib-common &&\
    mkdir build && cd build &&\
    cmake -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          .. &&\
    make -j ${GCC_JOBS} install
ENV YARP_DATA_DIRS=${YARP_DATA_DIRS:+${YARP_DATA_DIRS}:}${IIT_INSTALL}/share/ICUBcontrib

RUN cd ${IIT_SOURCES}/robot-testing &&\
    mkdir build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          -DENABLE_MIDDLEWARE_PLUGINS=ON \
          .. &&\
    make -j ${GCC_JOBS} install

RUN cd ${IIT_SOURCES}/ycm &&\
    mkdir build && cd build &&\
    cmake -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          .. &&\
    make -j ${GCC_JOBS} install

RUN cd ${IIT_SOURCES}/gazebo-yarp-plugins &&\
    mkdir build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          .. &&\
    make -j ${GCC_JOBS} install
ENV YARP_DATA_DIRS=${YARP_DATA_DIRS:+${YARP_DATA_DIRS}:}${IIT_INSTALL}/share/ICUBcontrib
ENV GAZEBO_PLUGIN_PATH=${GAZEBO_PLUGIN_PATH:+${GAZEBO_PLUGIN_PATH}:}${IIT_INSTALL}/lib

RUN cd ${IIT_SOURCES}/codyco-superbuild &&\
    mkdir build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DCODYCO_USES_GAZEBO:BOOL=ON \
          -DNON_INTERACTIVE_BUILD=ON \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          .. &&\
    make -j ${GCC_JOBS}
ENV CODYCO_SUPERBUILD_ROOT=${IIT_SOURCES}/codyco-superbuild
ARG CODYCO_SUPERBUILD_INSTALL=${CODYCO_SUPERBUILD_ROOT}/build/install
ENV IIT_PATH=${IIT_PATH:+${IIT_PATH}:}${CODYCO_SUPERBUILD_ROOT}/build/install/bin
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${CODYCO_SUPERBUILD_INSTALL}/lib
ENV YARP_DATA_DIRS=${YARP_DATA_DIRS:+${YARP_DATA_DIRS}:}${CODYCO_SUPERBUILD_INSTALL}/share/codyco
ENV GAZEBO_PLUGIN_PATH=${GAZEBO_PLUGIN_PATH:+${GAZEBO_PLUGIN_PATH}:}${CODYCO_SUPERBUILD_INSTALL}/lib
ENV GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH:+${GAZEBO_MODEL_PATH}:}${CODYCO_SUPERBUILD_INSTALL}/share/gazebo/models
ENV GAZEBO_RESOURCE_PATH=${GAZEBO_RESOURCE_PATH:+${GAZEBO_RESOURCE_PATH}:}${CODYCO_SUPERBUILD_INSTALL}/share/gazebo/worlds
ENV PATH=${IIT_PATH}:${ROOT_PATH}

# Some QT-Apps/Gazebo don't show controls without this
ENV QT_X11_NO_MITSHM 1

# Include a custom bashrc
COPY bashrc /usr/etc/skel/bashrc-dev

# Setup an additional entrypoint script
# For the time being it only creates a new runtime user
COPY entrypoint.sh /usr/sbin/entrypoint-dev.sh
RUN chmod 755 /usr/sbin/entrypoint-dev.sh
ENTRYPOINT ["/usr/sbin/entrypoint-dev.sh"]
