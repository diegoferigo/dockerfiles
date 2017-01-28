FROM ros:kinetic
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

# Install ROS Desktop Full
RUN apt-get update && apt-get install -y \
        ros-kinetic-desktop-full \
        ros-kinetic-fake-localization \
        ros-kinetic-map-server &&\
    rm -rf /var/lib/apt/lists/*

# Install YARP and iCub
RUN sh -c 'echo "deb http://www.icub.org/ubuntu xenial contrib/science" > /etc/apt/sources.list.d/icub.list' &&\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 57A5ACB6110576A6 &&\
    apt-get update &&\
    apt-get install -y \
        yarp \
        icub &&\
    rm -rf /var/lib/apt/lists/*

# Install other packages
RUN apt-get update && \
    apt-get install -y \
        software-properties-common \
        wget \
        nano \
        tree \
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

# Install additional development tools
RUN apt-get update &&\
    apt-get install -y \
      build-essential \
      git \
      cmake \
      llvm \
      clang \
      libclang-dev \
      gdb \
      valgrind &&\
    rm -rf /var/lib/apt/lists/*

# Packages with no ppa
ARG GITKRAKEN_VER=2.0.1
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
RUN apm install \
        build \
        build-make \
        build-cmake \
        busy \
        linter \
        linter-clang \
        autocomplete-clang \
        autocomplete-cmake \
        autocomplete-xml \
        atomic-rtags \
        highlight-selected \
        xml-formatter \
        atom-ros \
        atom-gdb \
        minimap \
        minimap-cursorline \
        minimap-linter \
        minimap-highlight-selected \
        minimap-codeglance \
        language-cmake \
        language-docker

# Install libraries
RUN apt-get update &&\
    apt-get install -y \
        libeigen3-dev &&\
    rm -rf /var/lib/apt/lists/*

# Some QT-Apps/Gazebo don't show controls without this
ENV QT_X11_NO_MITSHM 1

# Setup an additional entrypoint script
# For the time being it only creates a new runtime user
COPY entrypoint.sh /usr/sbin/entrypoint.sh
RUN chmod 755 /usr/sbin/entrypoint.sh
ENTRYPOINT ["/usr/sbin/entrypoint.sh"]
CMD ["bash"]
