`docker-compose` configuration for my complete development environment.
My usual setup consists of:

* Atom Editor + Atom packages
* GitKraken

The composed system consists of the following containers:

* **`development` container:** Atom Editor (`Development`)
* **`gitkraken` container:** GitKraken (`Development`)
* **`ros-master` container:** `roscore` (`ROS`)
* **`yarp-master` container:** Yarp Server (`YARP`)

In order to start the development environment, execute the helper script:
```bash
./docker-workspace start
```

For closing it, execute:
```bash
./docker-workspace stop
```
