Dockerfile for ROS Desktop Full, built on top of the ros:kinetic official image

X11 access enabled for GUIs

Please note that the final image requires 3.66GB

## Build the image
```
# docker build diego/ros-desktop-full .
```

## Run the image

Start the image with roscore as default process
```
# xhost +
# docker run -i -t --rm --privileged -e "DISPLAY" --security-opt="label:disable" -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v /host/folder:/ros -w /ros --name="ros" diego/ros-desktop-full roscore
```
Create as many ttys as you need with
```
# docker exec -it ros bash
```
Remember to launch `xhost -` when you don't need anymore the container

## TODO
* Setup a ROS [docker-compose][1] system (or https://hub.docker.com/_/ros/ - Compose)
* Try implementing a [more secure][2] way to share X

[1]: http://toddsampson.com/post/131227320927/docker-experimental-networking-and-ros
[2]: http://wiki.ros.org/docker/Tutorials/GUI
