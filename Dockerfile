FROM ubuntu:focal-20210723

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y \
        vim git build-essential curl wget dirmngr gnupg2 lsb-release python3-pip \
        apt-transport-https ca-certificates software-properties-common locales \
        libatlas-base-dev \
        liblapack-dev \
        libblas-dev \
        gfortran \
        tmux \
        tree \
        nano


## Install ROS Noetic (from uni tokyo)
RUN bash -c ' \
    echo "deb http://packages.ros.org.jsk.imi.i.u-tokyo.ac.jp/ros/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros-latest.list \
    && wget http://ros.jsk.imi.i.u-tokyo.ac.jp/jsk.key -O - | apt-key add - \
    && apt-get update -y && apt-get install -y ros-noetic-ros-base python3-rosdep python3-catkin-tools \
'
RUN apt-get install -y \
    ros-noetic-navigation

RUN pip3 install --no-use-pep517 \
    levmar \
    numpy \
    setuptools \
    osrf-pycommon ## catkin-tools dep

WORKDIR /app/ros/catkin

RUN bash -c ' \
    cd /app/ros/catkin \
    && git clone \
        https://github.com/KelvinUser/ros-wifi-localization \
        /app/ros/catkin/src/ros-wifi-localization \
    && git -C /app/ros/catkin/src/ros-wifi-localization checkout e60524618128d3289935177e9c98d05947674f03 \
    && source /opt/ros/noetic/setup.bash \
    && apt-get update -y \
    && rosdep init && rosdep update \
    && rosdep install --from-paths src --ignore-src -r -y \
    && catkin build \
'

RUN pip3 install --no-use-pep517 \
    gpy \
    matplotlib

RUN echo 'source /opt/ros/noetic/setup.bash' >> /root/.bashrc \
    && echo 'source /app/ros/catkin/devel/setup.bash' >> /root/.bashrc

COPY b3test1.bag /app/ros/catkin/src/ros-wifi-localization/tests/bags/b3test1.bag
COPY b3map.yaml /app/ros/catkin/src/ros-wifi-localization/tests/maps/b3map.yaml
COPY b3map.pgm /app/ros/catkin/src/ros-wifi-localization/tests/maps/b3map.pgm
COPY test.p /app/ros/catkin/src/ros-wifi-localization/tests/bags/processed_data/test.p
