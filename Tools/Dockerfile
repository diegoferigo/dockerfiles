FROM ubuntu:zesty
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

# Build and development tools
RUN apt-get update &&\
    apt-get install -y \
        build-essential \
        git \
        cmake \
        cmake-curses-gui \
        ninja-build \
        llvm \
        clang \
        lldb \
        libclang-dev \
        gdb \
        valgrind \
        valkyrie \
        ccache \
        doxygen \
        &&\
    rm -rf /var/lib/apt/lists/*
ENV ROOT_PATH=$PATH

# Libraries

# Setup HW Acceleration for Intel graphic cards
RUN apt-get update &&\
    apt-get install -y \
        libgl1-mesa-glx \
        libgl1-mesa-dri &&\
    rm -rf /var/lib/apt/lists/*

# Other packages
RUN apt-get update &&\
    apt-get install -y \
        software-properties-common \
        apt-transport-https \
        wget \
        nano \
        dbus-x11 \
        tree \
        bash-completion \
        libgnome-keyring0 \
        gnupg2 \
        python-pip \
        python-pygments \
        colordiff \
        octave \
        &&\
    rm -rf /var/lib/apt/lists/* &&\
    pip install colour-valgrind

# Editor (Atom + plugins)
# In the future, check if libxss1 will become an atom package dependency
RUN add-apt-repository -y ppa:webupd8team/atom &&\
    apt-get update &&\
    apt-get install -y \
        libxss1 \
        atom &&\
    rm -rf /var/lib/apt/lists/*

# Packages with no ppa
# TODO: check optional dependencies
ENV GCC_JOBS=4
RUN git clone --recursive https://github.com/Andersbakken/rtags.git &&\
    cd rtags &&\
    mkdir build &&\
    cd build &&\
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 .. &&\
    make -j ${GCC_JOBS} &&\
    make install &&\
    rm -r /rtags
ARG GITKRAKEN_VER=3.2.0
RUN wget https://release.gitkraken.com/linux/v${GITKRAKEN_VER}.deb &&\
    apt install /v${GITKRAKEN_VER}.deb &&\
    rm /v${GITKRAKEN_VER}.deb

# Atom packages
COPY atom_packages.txt /usr/local/etc
RUN apm install --packages-file /usr/local/etc/atom_packages.txt

# Setup an additional entrypoint script
COPY entrypoint.sh /usr/sbin/entrypoint.sh
RUN chmod 755 /usr/sbin/entrypoint.sh
ENTRYPOINT ["/usr/sbin/entrypoint.sh"]
CMD ["bash"]
