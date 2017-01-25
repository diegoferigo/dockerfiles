Dockerfile for YARP and iCub, built on top of latest ubuntu xenial image.

Features:
* X11 authentication for GUIs
* Image size: 2.45GB
* User created during runtime

## Build the image
```
 docker build -t diego/yarp .
```

## Run the container w/ yarp
```
docker run -i -t --rm \
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

## TODO
* YARP dynamically opens ports. Check how to handle its behavior
* HW Acceleration

## Resources
* [ROS dockerfile README][1]

[1]: https://github.com/diegoferigo/dockerfiles/tree/master/ROS
