FROM diegoferigo/tools
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

# Install ROS Desktop Full
# ========================

# Get gazebo8 from the osrf repo
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' &&\
    wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - &&\
    apt-get update &&\
    apt-get install --no-install-recommends -y \
        gazebo8 \
        libgazebo8-dev \
        &&\
    rm -rf /var/lib/apt/lists/*

# https://github.com/osrf/docker_images/blob/master/ros/
# ENV ROS_DISTRO lunar
# RUN apt-key adv --keyserver ha.pool.sks-keyservers.net \
#                 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116 &&\
#     echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -cs` main" \
#         > /etc/apt/sources.list.d/ros-latest.list
# RUN apt-get update &&\
#     apt-get install --no-install-recommends -y \
#         python-rosdep \
#         python-rosinstall \
#         python-vcstools \
#         &&\
#     rm -rf /var/lib/apt/lists/* &&\
#     rosdep init &&\
#     rosdep update
# RUN apt-get update &&\
#     apt-get install -y \
#         ros-${ROS_DISTRO}-desktop \
#         # ros-${ROS_DISTRO}-desktop-full &&\
#         #ros-${ROS_DISTRO}-fake-localization \
#         #ros-${ROS_DISTRO}-map-server &&\
#         &&\
#     rm -rf /var/lib/apt/lists/*

# Install libraries and tools
# ===========================

RUN apt-get update &&\
    apt-get install -y \
        # MISC
        qt5-default \
        # SWIG
        autotools-dev \
        automake \
        bison \
        # YARP
        libeigen3-dev \
        libgsl-dev \
        libedit-dev \
        libqcustomplot-dev \
        qtmultimedia5-dev \
        qtdeclarative5-dev \
        libqt5opengl5-dev \
        qttools5-dev \
        # GAZEBO-YARP-PLUGINS
        libatlas-base-dev \
        # IDYNTREE
        coinor-libipopt-dev \
        # BINDINGS
        liboctave-dev \
        # SIMMECHANICS-TO-URDF
        python-lxml \
        python-yaml \
        python-numpy \
        python-setuptools \
        &&\
    rm -rf /var/lib/apt/lists/*

# Concurrent compilation jobs
ENV GCC_JOBS=6

# Install YARP, iCub and friends from sources
# ===========================================

# Environment setup of the robotology repositories
# ------------------------------------------------

ENV IIT_DIR=/iit
ENV IIT_INSTALL=${IIT_DIR}/local
ENV IIT_SOURCES=${IIT_DIR}/sources
ARG IIT_BIN=${IIT_INSTALL}/bin
ENV IIT_PATH=${IIT_PATH:+${IIT_PATH}:}${IIT_BIN}
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${IIT_INSTALL}/lib/
ENV PATH=${IIT_PATH}:${PATH}

# Download all sources with git
# -----------------------------

RUN mkdir -p ${IIT_SOURCES} ${IIT_BIN}

# Use docker cache for steps above
ARG IIT_DOCKER_SOURCES="20171214"

RUN cd ${IIT_SOURCES} &&\
    git clone https://github.com/robotology/ycm.git &&\
    git clone https://github.com/robotology/yarp.git &&\
    git clone https://github.com/robotology/icub-main.git &&\
    git clone https://github.com/robotology/icub-contrib-common.git &&\
    git clone https://github.com/robotology/robot-testing.git &&\
    git clone https://github.com/robotology/gazebo-yarp-plugins.git &&\
    git clone https://github.com/robotology-playground/yarp-matlab-bindings.git &&\
    git clone https://github.com/robotology/idyntree.git &&\
    git clone https://github.com/ros/urdf_parser_py &&\
    git clone https://github.com/robotology/simmechanics-to-urdf.git &&\
    git clone https://github.com/robotology-playground/icub-model-generator.git &&\
    git clone https://github.com/robotology/codyco-superbuild.git

# Env variables for configuring the sources
# -----------------------------------------

# Build Variables
ARG SOURCES_GIT_BRANCH=devel
ENV SOURCES_BUILD_TYPE=Release

# Select the main development robot (model loading)
ENV ROBOT_NAME="iCubGazeboV2_5"
ENV YARP_ROBOT_NAME="iCubGazeboV2_5"

# Configure the MEX provider
# For the time being, ROBOTOLOGY_USES_MATLAB=ON is not supported.
# Refer to https://github.com/diegoferigo/dockerfiles/issues/8
ENV ROBOTOLOGY_USES_OCTAVE=ON
ENV ROBOTOLOGY_USES_MATLAB=OFF
ENV ROBOTOLOGY_GENERATE_MEX=ON
# The default is "mex" but "matlab" should become the default
ENV ROBOTOLOGY_MATLAB_MEX_DIR="matlab"

# Build all sources
# -----------------

# YCM
RUN cd ${IIT_SOURCES}/ycm &&\
    git checkout ${SOURCES_GIT_BRANCH} &&\
    mkdir -p build && cd build &&\
    cmake -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          .. &&\
    make -j ${GCC_JOBS} install

# YARP
RUN \
    cd ${IIT_SOURCES}/yarp &&\
    git checkout ${SOURCES_GIT_BRANCH} &&\
    mkdir -p build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          -DCREATE_GUIS=ON \
          -DCREATE_LIB_MATH=ON \
          -DSKIP_ACE=ON \
          .. &&\
    make -j ${GCC_JOBS} install &&\
    ln -s ${IIT_SOURCES}/yarp/scripts/yarp_completion \
          /etc/bash_completion.d/yarp_completion
ENV YARP_DIR=${IIT_INSTALL}
ENV YARP_DATA_DIRS=${IIT_INSTALL}/share/yarp
ENV YARP_COLORED_OUTPUT=1
RUN yarp check
EXPOSE 10000/tcp

# ICUB-MAIN
RUN cd ${IIT_SOURCES}/icub-main &&\
    git checkout ${SOURCES_GIT_BRANCH} &&\
    mkdir -p build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          -DENABLE_icubmod_cartesiancontrollerserver=ON \
          -DENABLE_icubmod_cartesiancontrollerclient=ON \
          -DENABLE_icubmod_gazecontrollerclient=ON \
          .. &&\
    make -j ${GCC_JOBS} install
ENV YARP_DATA_DIRS=${YARP_DATA_DIRS:+${YARP_DATA_DIRS}:}${IIT_INSTALL}/share/iCub

# ICUB-CONTRIB-COMMON
RUN cd ${IIT_SOURCES}/icub-contrib-common &&\
    mkdir -p build && cd build &&\
    cmake -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          .. &&\
    make -j ${GCC_JOBS} install
ENV YARP_DATA_DIRS=${YARP_DATA_DIRS:+${YARP_DATA_DIRS}:}${IIT_INSTALL}/share/ICUBcontrib

# ROBOT-TESTING
RUN cd ${IIT_SOURCES}/robot-testing &&\
    git checkout ${SOURCES_GIT_BRANCH} &&\
    mkdir -p build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          -DENABLE_MIDDLEWARE_PLUGINS=ON \
          .. &&\
    make -j ${GCC_JOBS} install

# GAZEBO-YARP-PLUGINS
RUN cd ${IIT_SOURCES}/gazebo-yarp-plugins &&\
    git checkout ${SOURCES_GIT_BRANCH} &&\
    mkdir -p build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          .. &&\
    make -j ${GCC_JOBS} install
ENV YARP_DATA_DIRS=${YARP_DATA_DIRS:+${YARP_DATA_DIRS}:}${IIT_INSTALL}/share/ICUBcontrib
ENV GAZEBO_PLUGIN_PATH=${GAZEBO_PLUGIN_PATH:+${GAZEBO_PLUGIN_PATH}:}${IIT_INSTALL}/lib

# YARP-MATLAB-BINDINGS
RUN cd ${IIT_SOURCES}/yarp-matlab-bindings &&\
    git checkout ${SOURCES_GIT_BRANCH} &&\
    # Waiting https://github.com/robotology-playground/yarp-matlab-bindings/issues/18
    rm matlab/autogenerated/yarpMATLAB_wrap.cxx &&\
    mkdir -p build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          -DYARP_SOURCE_DIR=${IIT_SOURCES}/yarp \
          -DYARP_USES_OCTAVE:BOOL=${ROBOTOLOGY_USES_OCTAVE} \
          -DYARP_USES_MATLAB:BOOL=${ROBOTOLOGY_USES_MATLAB} \
          -DYARP_GENERATE_MATLAB:BOOL=${ROBOTOLOGY_GENERATE_MEX} \
          -DYARP_INSTALL_MATLAB_LIBDIR=${ROBOTOLOGY_MATLAB_MEX_DIR} \
          -DYARP_INSTALL_MATLAB_MFILESDIR=${ROBOTOLOGY_MATLAB_MEX_DIR} \
          -DYCM_USE_DEPRECATED:BOOL=OFF \
          .. &&\
    make -j ${GCC_JOBS} install

# IDYNTREE
RUN cd ${IIT_SOURCES}/idyntree &&\
    git checkout ${SOURCES_GIT_BRANCH} &&\
    mkdir -p build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          -DIDYNTREE_USES_OCTAVE:BOOL=${ROBOTOLOGY_USES_OCTAVE} \
          -DIDYNTREE_USES_MATLAB:BOOL=${ROBOTOLOGY_USES_MATLAB} \
          -DIDYNTREE_GENERATE_MATLAB:BOOL=${ROBOTOLOGY_GENERATE_MEX} \
          -DIDYNTREE_INSTALL_MATLAB_LIBDIR=${ROBOTOLOGY_MATLAB_MEX_DIR} \
          -DIDYNTREE_INSTALL_MATLAB_MFILESDIR=${ROBOTOLOGY_MATLAB_MEX_DIR} \
          -DIDYNTREE_USES_KDL:BOOL=OFF \
          -DYCM_USE_DEPRECATED=OFF \
          .. &&\
    make -j ${GCC_JOBS} install

# ICUB-GAZEBO-WHOLEBODY
RUN cd ${IIT_SOURCES} &&\
    git clone https://github.com/robotology-playground/icub-gazebo-wholebody.git &&\
    cd ${IIT_SOURCES}/icub-gazebo-wholebody &&\
    git checkout feature/useGeneratedModels &&\
    mkdir -p build && cd build &&\
    cmake -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          -DROBOT_NAME=${ROBOT_NAME} \
          .. &&\
    make -j ${GCC_JOBS} install
ENV GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH:+${GAZEBO_MODEL_PATH}:}${IIT_INSTALL}/share/gazebo/models/

# ICUB-MODELS
RUN cd ${IIT_SOURCES} &&\
    git clone https://github.com/robotology-playground/icub-models &&\
    cd ${IIT_SOURCES}/icub-models &&\
    mkdir -p build && cd build &&\
    cmake -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          .. &&\
    make install
ENV YARP_DATA_DIRS=${YARP_DATA_DIRS:+${YARP_DATA_DIRS}:}${IIT_INSTALL}/share/iCub
ENV GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH:+${GAZEBO_MODEL_PATH}:}${IIT_INSTALL}/share/iCub/robots:${IIT_INSTALL}/share
ENV ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH:+${ROS_PACKAGE_PATH}:}${IIT_INSTALL}/share
ENV GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH:+${GAZEBO_MODEL_PATH}:}${IIT_INSTALL}/share

# SIMMECHANICS-TO-URDF
ENV ROS_DISTRO lunar
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net \
                --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116 &&\
    echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -cs` main" \
        > /etc/apt/sources.list.d/ros-latest.list &&\
    apt-get update &&\
    apt-get install --no-install-recommends -y \
        python-catkin-pkg \
        &&\
    rm -rf /var/lib/apt/lists/*
RUN \
    # Dependencies
    cd ${IIT_SOURCES}/urdf_parser_py &&\
    python setup.py install &&\
    # Project
    cd ${IIT_SOURCES}/simmechanics-to-urdf &&\
    python setup.py install

# ICUB-MODEL-GENERATOR
RUN cd ${IIT_SOURCES}/icub-model-generator &&\
    mkdir -p build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
          -DICUB_MODEL_GENERATE_DH:BOOL=OFF \
          -DICUB_MODEL_GENERATE_SIMMECHANICS:BOOL=ON \
          -DICUB_MODELS_SOURCE_DIR=${IIT_SOURCES}/icub-models \
          .. &&\
    make -j ${GCC_JOBS}

# CODYCO-SUPERBUILD
RUN cd ${IIT_SOURCES}/codyco-superbuild &&\
    mkdir -p build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DCODYCO_USES_GAZEBO:BOOL=ON \
          -DNON_INTERACTIVE_BUILD:BOOL=ON \
          -DCODYCO_USES_OCTAVE:BOOL=${ROBOTOLOGY_USES_OCTAVE} \
          -DCODYCO_USES_MATLAB:BOOL=${ROBOTOLOGY_USES_MATLAB} \
          -DCODYCO_USES_WBI_TOOLBOX_CONTROLLERS=${ROBOTOLOGY_USES_MATLAB} \
          -DCODYCO_NOT_USE_YARP_MATLAB_BINDINGS:BOOL=ON \
          -DCODYCO_USES_KDL:BOOL=OFF \
          -DYCM_USE_DEPRECATED:BOOL=OFF \
          -DYCM_EP_EXPERT_MODE:BOOL=ON \
          -DYCM_EP_MAINTAINER_MODE:BOOL=ON \
          .. &&\
    make -j ${GCC_JOBS}

# Set the codyco-superbuild environment up
ENV CODYCO_SUPERBUILD_ROOT=${IIT_SOURCES}/codyco-superbuild
ENV CODYCO_SUPERBUILD_INSTALL=${CODYCO_SUPERBUILD_ROOT}/build/install
ENV IIT_PATH=${IIT_PATH:+${IIT_PATH}:}${CODYCO_SUPERBUILD_ROOT}/build/install/bin
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${CODYCO_SUPERBUILD_INSTALL}/lib
ENV YARP_DATA_DIRS=${YARP_DATA_DIRS:+${YARP_DATA_DIRS}:}${CODYCO_SUPERBUILD_INSTALL}/share/codyco
ENV GAZEBO_PLUGIN_PATH=${GAZEBO_PLUGIN_PATH:+${GAZEBO_PLUGIN_PATH}:}${CODYCO_SUPERBUILD_INSTALL}/lib
ENV GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH:+${GAZEBO_MODEL_PATH}:}${CODYCO_SUPERBUILD_INSTALL}/share/gazebo/models
ENV GAZEBO_RESOURCE_PATH=${GAZEBO_RESOURCE_PATH:+${GAZEBO_RESOURCE_PATH}:}${CODYCO_SUPERBUILD_INSTALL}/share/gazebo/worlds
ENV PATH=${IIT_PATH}:${ROOT_PATH}

# Misc setup of the image
# =======================

# Some QT-Apps/Gazebo don't show controls without this
ENV QT_X11_NO_MITSHM 1

# Include a custom bashrc
COPY bashrc /usr/etc/skel/bashrc-dev
COPY bashrc-colors /usr/etc/skel/bashrc-colors

# Include an additional entrypoint script
COPY entrypoint.sh /usr/sbin/entrypoint_development.sh
RUN chmod 755 /usr/sbin/entrypoint_development.sh
COPY setup.sh /usr/sbin/setup_development.sh
RUN chmod 755 /usr/sbin/setup_development.sh
ENTRYPOINT ["/usr/sbin/entrypoint_development.sh"]

# nvidia-docker 1.0
LABEL com.nvidia.volumes.needed="nvidia_driver"

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
RUN ldconfig

ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}
