FROM ubuntu:yakkety
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

# Variables
ARG GITKRAKEN_VER=2.0.1

# The update is done only here and then cached
RUN apt-get update

# Build tools
RUN apt-get install -y \
        build-essential \
        git \
        cmake \
        llvm \
        clang \
        libclang-dev

# Libraries

# Other packages
RUN apt-get install -y \
        software-properties-common \
        wget \
        nano \
        curl \
        dbus-x11 \
        libgnome-keyring0 &&\
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

# Setup an additional entrypoint script
COPY entrypoint.sh /usr/sbin/entrypoint.sh
RUN chmod 755 /usr/sbin/entrypoint.sh
ENTRYPOINT ["/usr/sbin/entrypoint.sh"]
CMD ["bash"]
