Dockerfile for YARP, built on top of latest ubuntu xenial image

# Build the image
```
# docker build diego/yarp .
```

# Run the container w/ yarp
```
# docker run -p 10000:10000 -i -t --rm --name "yarp" diego/yarp bash
```
Open as many ttys as you need
```
# docker exec -it yarp bash
```

# X11 host access
```
# docker run -p 10000:10000 -i -t --rm --privileged -e "DISPLAY" --security-opt="label:disable" -v /tmp/.X11-unix:/tmp/.X11-unix:rw --name "yarp" diego/yarp bash
```
