`docker-compose` configuration for my complete development environment.
My usual setup consists of:

* Atom Editor + Atom packages
* GitKraken

The composed system consists of the following containers:

* **`development` container:** Atom Editor (`Development`)
* **`gitkraken` container:** GitKraken (`Development`)
* **`ros-master` container:** `roscore` (`ROS`)
* **`yarp-server` container:** Yarp Server (`YARP`)

In order to start the development environment, execute the helper script:
```bash
./docker-workspace.sh start
```

For closing it, execute:
```bash
./docker-workspace.sh stop
```

## Resources:
* [`docker-library` documentation on ROS][1]
* [Docker Experimental Networking and ROS][2]

[1]: https://github.com/docker-library/docs/tree/master/ros#compose
[2]: http://toddsampson.com/post/131227320927/docker-experimental-networking-and-ros
