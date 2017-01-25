Dockerfile for YARP and iCub, built on top of latest ubuntu xenial image.

Features:
* X11 authentication for GUIs
* Image size: 2.45GB
* User created during runtime

## Build the image
```
 docker build -t diego/yarp .
```

## User configuration
This docker image allows the creation of a runtime user,
whose default UID and GID is 1000.
To override these values and to start the container, execute:
```
USER_UID=1000
USER_GID=1000
USERNAME=foo

docker run -i -t --rm \
	-e USER_UID=$USER_UID \
	-e USER_GID=$USER_GID \
	-e USERNAME=$USERNAME \
	-p 10000:10000 \
	--name yarp \
	diego/yarp \
	bash
```
Then, open as many ttys as needed with
```
docker exec -it yarp bash
```

## X11 host access
```
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth

touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

docker run -i -t --rm \
	-p 10000:10000 \
	-v $XSOCK:$XSOCK:rw \
	-v $XAUTH:$XAUTH:rw \
	-e XAUTHORITY=${XAUTH} \
	-e "DISPLAY" \
	--name yarp \
	diego/yarp \
	iCubGui
```
If you need HW acceleration (only for Intel graphic cards), add also this device
flag `--device=/dev/dri`.

## TODO
* YARP dynamically opens ports. Check how to handle its behavior

## Resources
* [ROS dockerfile README][1]

[1]: https://github.com/diegoferigo/dockerfiles/tree/master/ROS
