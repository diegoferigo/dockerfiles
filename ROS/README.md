Dockerfile for ROS Kinetic `desktop-full`, built on top of the ros:kinetic official image

Features:
* X11 authentication for GUIs
* Image size: 3.66GB

## Build the image
```
docker build -t diego/ros-desktop-full .
```

## Run the container

Start the container with roscore as default process
```
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
touch $XAUTH

docker run -i -t --rm \
	-v $XSOCK:$XSOCK:rw \
	-v $XAUTH:$XAUTH:rw \
	-e XAUTHORITY=${XAUTH} \
	-e "DISPLAY" \
	-v /host/folder:/ros \
	-w /ros \
	--name="ros" \
	diego/ros-desktop-full \
	roscore
```
Then, create as many ttys as needed with
```
docker exec -it ros bash
```

## Resources
* [Docker and ROS][0]
* X11 Authentication: [stackoverflow][1], [ROS Wiki][2]

## TODO
* [Hardware Acceleration][3]
* Setup a ROS [docker-compose][4] system (see also [docker hub][5] - Compose)

[0]: http://wiki.ros.org/docker/Tutorials
[1]: https://stackoverflow.com/questions/16296753/can-you-run-gui-apps-in-a-docker-container
[2]: http://wiki.ros.org/docker/Tutorials/GUI
[3]: http://wiki.ros.org/docker/Tutorials/Hardware%20Acceleration
[4]: http://toddsampson.com/post/131227320927/docker-experimental-networking-and-ros
[5]: https://hub.docker.com/_/ros/
