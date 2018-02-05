FROM ubuntu:artful
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

# Utilities
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

# Updated clang ppa
RUN wget -nv -O - http://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - &&\
    apt-add-repository -y "deb http://apt.llvm.org/`lsb_release -cs`/ llvm-toolchain-`lsb_release -cs`-5.0 main" &&\
    rm -rf /var/lib/apt/lists/*

# Build and development tools
RUN apt-get update &&\
    apt-get install -y \
        build-essential \
        git \
        cmake \
        cmake-curses-gui \
        ninja-build \
        llvm-5.0 \
        clang-5.0 \
        lldb-5.0 \
        libclang-5.0-dev \
        clang-format-5.0 \
        gdb \
        valgrind \
        valkyrie \
        ccache \
        doxygen \
        &&\
    rm -rf /var/lib/apt/lists/*
ENV ROOT_PATH=$PATH

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
ARG GITKRAKEN_VER=3.3.1
RUN wget https://release.gitkraken.com/linux/v${GITKRAKEN_VER}.deb &&\
    apt install /v${GITKRAKEN_VER}.deb &&\
    rm /v${GITKRAKEN_VER}.deb

# Atom packages
COPY atom_packages.txt /usr/local/etc
RUN apm install --packages-file /usr/local/etc/atom_packages.txt

# Setup an additional entrypoint script
COPY setup.sh /usr/sbin/setup_tools.sh
COPY entrypoint.sh /usr/sbin/entrypoint_tools.sh
RUN chmod 755 /usr/sbin/setup_tools.sh
RUN chmod 755 /usr/sbin/entrypoint_tools.sh
ENTRYPOINT ["/usr/sbin/entrypoint_tools.sh"]
CMD ["bash"]
