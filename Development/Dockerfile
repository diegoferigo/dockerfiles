FROM ros:kinetic
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

# Install ROS Desktop Full
RUN apt-get update && apt-get install -y \
        ros-kinetic-desktop-full \
        ros-kinetic-fake-localization \
        ros-kinetic-map-server &&\
    rm -rf /var/lib/apt/lists/*

# Install other packages
RUN apt-get update && \
    apt-get install -y \
        software-properties-common \
        wget \
        nano \
        dbus-x11 \
        tree \
        bash-completion \
        libgnome-keyring0 &&\
    rm -rf /var/lib/apt/lists/*

# Setup HW Acceleration for Intel graphic cards
RUN apt-get update &&\
    apt-get install -y \
        libgl1-mesa-glx \
        libgl1-mesa-dri &&\
    rm -rf /var/lib/apt/lists/*

# Editor (Atom + plugins)
# In the future, check if libxss1 will become an atom package dependency
RUN add-apt-repository -y ppa:webupd8team/atom &&\
    apt-get update &&\
    apt-get install -y \
        libxss1 \
        atom &&\
    rm -rf /var/lib/apt/lists/*

# Install additional build and development tools
RUN apt-get update &&\
    apt-get install -y \
        build-essential \
        git \
        cmake \
        cmake-curses-gui \
        llvm \
        clang \
        libclang-dev \
        gdb \
        valgrind \
        ccache \
        doxygen &&\
    rm -rf /var/lib/apt/lists/*
ARG ROOT_PATH=$PATH
ENV PATH=/usr/lib/ccache:${ROOT_PATH}

# Packages with no ppa
ARG GITKRAKEN_VER=2.1.0
RUN wget https://release.gitkraken.com/linux/v${GITKRAKEN_VER}.deb &&\
    apt install /v${GITKRAKEN_VER}.deb &&\
    rm /v${GITKRAKEN_VER}.deb
# TODO: check optional dependencies
RUN git clone --recursive https://github.com/Andersbakken/rtags.git &&\
    cd rtags &&\
    mkdir build &&\
    cd build &&\
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 .. &&\
    make &&\
    make install &&\
    rm -r /rtags

# Atom packages
COPY atom_packages.txt /usr/local/etc
RUN apm install --packages-file /usr/local/etc/atom_packages.txt

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
ARG IIT_SOURCES=${IIT_DIR}/sources
ARG IIT_BIN=${IIT_INSTALL}/bin
ENV IIT_PATH=${IIT_PATH:+${IIT_PATH}:}${IIT_BIN}
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${IIT_INSTALL}/lib/
ENV PATH=${IIT_PATH}:${PATH}

RUN mkdir -p ${IIT_SOURCES} ${IIT_BIN}

# Use cache for steps above
ARG IIT_DOCKER_SOURCES="v1"

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
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          -DCREATE_GUIS=ON \
          -DCREATE_LIB_MATH=ON \
          .. &&\
    make -j ${GCC_JOBS} install &&\
    ln -s ${IIT_SOURCES}/yarp/scripts/yarp_completion \
          /etc/bash_completion.d/yarp_completion
ENV YARP_DIR=${IIT_INSTALL}
ENV YARP_DATA_DIRS=${IIT_INSTALL}/share/yarp
RUN yarp check
EXPOSE 10000/tcp

RUN cd ${IIT_SOURCES}/icub-main &&\
    mkdir build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=Release \
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
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          -DENABLE_MIDDLEWARE_PLUGINS=ON \
          .. &&\
    make -j ${GCC_JOBS} install

RUN cd ${IIT_SOURCES}/ycm &&\
    mkdir build && cd build &&\
    cmake -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          .. &&\
    make -j ${GCC_JOBS} install

# TODO: codyco-superbuild does not recognize this plugin and rebuilds it.
#       The PackageConfig is missing
RUN cd ${IIT_SOURCES}/gazebo-yarp-plugins &&\
    mkdir build && cd build &&\
    cmake -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          .. &&\
    make -j ${GCC_JOBS} install
ENV YARP_DATA_DIRS=${YARP_DATA_DIRS:+${YARP_DATA_DIRS}:}${IIT_INSTALL}/share/ICUBcontrib
ENV GAZEBO_PLUGIN_PATH=${GAZEBO_PLUGIN_PATH:+${GAZEBO_PLUGIN_PATH}:}${IIT_INSTALL}/lib

RUN cd ${IIT_SOURCES}/codyco-superbuild &&\
    mkdir build && cd build &&\
    cmake -DCODYCO_USES_GAZEBO:BOOL=ON \
          -DNON_INTERACTIVE_BUILD=ON \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          .. &&\
    make -j ${GCC_JOBS}
ARG CODYCO_SUPERBUILD_ROOT=${IIT_SOURCES}/codyco-superbuild
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
COPY entrypoint.sh /usr/sbin/entrypoint.sh
RUN chmod 755 /usr/sbin/entrypoint.sh
ENTRYPOINT ["/usr/sbin/entrypoint.sh"]
CMD ["bash"]
