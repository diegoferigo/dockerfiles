FROM ubuntu:artful
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

# Utilities
RUN apt-get update &&\
    apt-get install -y \
        sudo \
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
        locales \
        &&\
    rm -rf /var/lib/apt/lists/* &&\
    pip install colour-valgrind

# Setup locales
RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen && \
    locale-gen &&\
    update-locale LANG="en_US.UTF-8"

# Updated clang ppa
ENV CLANG_VER=6.0
RUN wget -nv -O - http://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - &&\
    apt-add-repository -y "deb http://apt.llvm.org/`lsb_release -cs`/ llvm-toolchain-`lsb_release -cs`-${CLANG_VER} main"

# Build and development tools
RUN apt-get update &&\
    apt-get install -y \
        build-essential \
        git \
        cmake \
        cmake-curses-gui \
        ninja-build \
        llvm-${CLANG_VER} \
        clang-${CLANG_VER} \
        lldb-${CLANG_VER} \
        libclang-${CLANG_VER}-dev \
        clang-format-${CLANG_VER} \
        gdb \
        valgrind \
        valkyrie \
        ccache \
        doxygen \
        &&\
    rm -rf /var/lib/apt/lists/*

# Setup HW Acceleration for Intel graphic cards
RUN apt-get update &&\
    apt-get install -y \
        libgl1-mesa-glx \
        libgl1-mesa-dri &&\
    rm -rf /var/lib/apt/lists/*

# Atom Editor
# In the future, check if libxss1 will become an atom package dependency
RUN add-apt-repository -y ppa:webupd8team/atom &&\
    apt-get update &&\
    apt-get install -y \
        libxss1 \
        atom &&\
    rm -rf /var/lib/apt/lists/*

# Atom packages
COPY atom_packages.txt /usr/local/etc
RUN apm install --packages-file /usr/local/etc/atom_packages.txt

# Packages with no ppa
# ====================

# QtCreator
ARG QTCREATOR_VERSION=4.5.0
COPY QtCreatorSetup.js /tmp/QtCreatorSetup.js
RUN cd /tmp &&\
    wget http://download.qt.io/official_releases/qtcreator/${QTCREATOR_VERSION%.*}/${QTCREATOR_VERSION}/qt-creator-opensource-linux-x86_64-$QTCREATOR_VERSION.run &&\
    chmod +x qt-creator-opensource-linux-x86_64-${QTCREATOR_VERSION}.run &&\
    ./qt-creator-opensource-linux-x86_64-${QTCREATOR_VERSION}.run --platform minimal --script QtCreatorSetup.js &&\
    rm /tmp/qt-creator-opensource-linux-x86_64-${QTCREATOR_VERSION}.run /tmp/QtCreatorSetup.js
ENV PATH=$PATH:/opt/qtcreator/bin

# Gitkraken
ARG GITKRAKEN_VER=3.3.4
RUN cd /tmp &&\
    wget https://release.gitkraken.com/linux/v${GITKRAKEN_VER}.deb &&\
    apt install /tmp/v${GITKRAKEN_VER}.deb &&\
    rm v${GITKRAKEN_VER}.deb

# rr
RUN apt-get update &&\
    apt-get install -y \
        ccache \
        cmake \
        make \
        g++-multilib \
        gdb \
        pkg-config \
        realpath \
        python-pexpect \
        manpages-dev \
        git \
        ninja-build \
        capnproto \
        libcapnp-dev &&\
    rm -rf /var/lib/apt/lists/* &&\
    cd /tmp &&\
    git clone https://github.com/mozilla/rr.git &&\
    cd rr && mkdir build && cd build &&\
    CC=clang-${CLANG_VER} CXX=clang++-${CLANG_VER} cmake -G Ninja .. &&\
    cmake --build . &&\
    cmake --build . --target install &&\
    rm -r /tmp/rr

# SWIG with Matlab / Octave support
# ... waiting its upstream merge
RUN apt-get update &&\
    apt-get install -y \
        autotools-dev \
        automake \
        bison \
        libpcre3-dev &&\
    rm -rf /var/lib/apt/lists/* &&\
    cd /tmp/ &&\
    git clone https://github.com/jaeandersson/swig.git &&\
    cd swig &&\
    git checkout matlab &&\
    sh autogen.sh &&\
    CC=clang-${CLANG_VER} CXX=clang++-${CLANG_VER} ./configure &&\
    make -j2 &&\
    make install &&\
    rm -r /tmp/swig

# Setup an additional entrypoint script
COPY setup.sh /usr/sbin/setup_tools.sh
COPY entrypoint.sh /usr/sbin/entrypoint_tools.sh
RUN chmod 755 /usr/sbin/setup_tools.sh
RUN chmod 755 /usr/sbin/entrypoint_tools.sh
ENTRYPOINT ["/usr/sbin/entrypoint_tools.sh"]
CMD ["bash"]
