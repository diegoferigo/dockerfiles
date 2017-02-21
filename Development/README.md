Dockerfile for my complete development environment. This image is mostly a merge
of `ROS`, `YARP`, and `Tools` images. This is a fully portable environment, ready
out-out-the-box in just a bunch of minutes.

**Disclaimer:** This Docker image looks more to an isolated VM rather than a container!

**This image is project related**. It is not supposed to be used as it is for other
purpose, if you are looking for more general images, check `Anaconda`, `ROS`,
`Tools`, and `YARP` folders.

Its start is demanded to a `docker-compose` system. Check the `compose` folder
for details.

## Features:
* Image size: 5.8GB
* Development setup working out-of-the-box
* X11 authentication for GUIs
* User created during runtime
* Atom Editor + Atom packages for C++ + GitKraken
* Persistent Atom and GitKraken configuration

## Build the image
```
docker build --rm -t diego/development .
```

### TODO:
* Fix the problem when mounting the configuration folders
