Dockerfile for my development tools I daily use for programming, including:
* Atom Editor
* Atom plugins for C++ / ROS
* GitKraken

This Dockerfile includes software either downloaded outside ppa and built from
source during the image creation. This is not the cleanest solution, but without
dedicated repositories it is the only way.

The Atom and GitKraken user's configuration could be made persistent by mounting
respectively `~/.atom` and `~/.gitkraken` as volumes.<br>
Note that the folder containing the atom packages will be populated with symlinks
pointing to the packages shipped with this image. If you use Atom also in your
host system, to keep the setups separated you can consider mounting a different
folder instead of `~/.atom`.

### Image Features:
* Image size: 1.8GB
* Out-of-the-box development setup, quickly portable on any machine
* X11 authentication for GUIs
* User created during runtime

In order to fully exploit the Atom packages shipped with this image, it should
contain all the toolchain and libraries to build your project. For this reason,
this image could be useful as starting point to build a reproducible development
setup. Code testing could be performed with a much simpler container (or
docker-compose system).

### Atom Features:
* [RTags][2] enabled by default ([package][2], [usage][3] - only cmake supported).
Atom could auto spawn it (check the package preferences).
* [C++ linter][16] with clang
* [autocomplete-clang][17]
* Many more atom plugins (check Dockerfile)

`RTags` work flawlessly with `cmake`, just add the `-DCMAKE_EXPORT_COMPILE_COMMANDS=1`
flag, it will generate the `compile_commands.json` configuration file ([reference][8]).
RTags needs the execution of `rc -J` after CMake.

`linter-clang` and `clang-complete` need the `.clang_complete` file. Its generation
could be automated through [CMake][10].

In order to let `linter-clang` recognize C++ `.hpp` headers instead `.h`, use
this `~/.atom/config.cson` as default configuration:
```json
"*":
  "core":
    customFileTypes:
	   "source.cpp": [
		  "h"
	   ]
```

## Build the image
```
 docker build -t diego/tools .
```

## User configuration
This docker image allows the creation of a runtime user,
whose default `UID` and `GID` is 1000. Since this image contains tools that perform
operations on files shared with the host system, in order to avoid file ownership
and permission issues, I recommend to use the same username of your host user.
To override the default values and to start the container, execute:
```
USER_UID=1000
USER_GID=1000
USERNAME=$(whoami)

docker run -i -t --rm \
	-e USER_UID=$USER_UID \
	-e USER_GID=$USER_GID \
	-e USERNAME=$USERNAME \
	--name tools \
	diego/tools \
	bash
```
Then, spawn as many ttys as needed with
```
docker exec -it tools bash
```

## X11 host access
Simple example to open Atom:
```
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth

touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

USERNAME=$(whoami)

docker run -i -t --rm \
	-v $XSOCK:$XSOCK:rw \
	-v $XAUTH:$XAUTH:rw \
	-e XAUTHORITY=$XAUTH \
	-e "DISPLAY" \
	-e USERNAME=$USERNAME
	--name tools \
	diego/tools \
	su -c "atom -f" $USERNAME
```
In order to run application as user and not root, remember to launch it with
`su -c "command_to_execute" $USERNAME`.

### TODO
* Explore systemd integration within container ([1][1], [2][5], [3][6], [4][7])
* `rdm` is started by atom, even if it is not the default option in `RTags` settings.
Is it worth to include systemd in the image to gracefully handle services like this?
([reference for rdm][18])
* `linter-clang` [should support][13] also the `compile_commands.json`.
Follow [this bug report][14].
* It would be great to have an atom package that handles ROS in the tree view
as [RoboWare][15]

### Resources
* [Atom, C++, and embedded development][9]
* [Awesome Atom][11]
* [Atom plugins for C++ development][12]

[1]: https://developers.redhat.com/blog/2016/09/13/running-systemd-in-a-non-privileged-container/
[2]: https://atom.io/packages/atomic-rtags
[3]: https://github.com/Andersbakken/rtags#setup
[5]: https://lwn.net/Articles/676831/
[6]: http://docs.projectatomic.io/container-best-practices/#planning_starting_application
[7]: https://maci0.wordpress.com/2014/07/23/run-systemd-in-an-unprivileged-docker-container/
[8]: http://clang.llvm.org/docs/JSONCompilationDatabase.html
[9]: http://blog.oakbits.com/index.php?post/2016/02/01/Using-Atom-For-C-And-Embedded-Development
[10]: https://ncrmnt.org/2016/04/21/cmake-atom-clang_complete/
[11]: https://github.com/mehcode/awesome-atom
[12]: https://blogs.aerys.in/jeanmarc-leroux/2015/07/31/atom-plugins-for-c-development/
[13]: https://github.com/AtomLinter/linter-clang#clang-json-compilation-database
[14]: https://github.com/AtomLinter/linter-clang/issues/131
[15]: http://www.roboware.me
[16]: https://atom.io/packages/linter-clang
[17]: https://atom.io/packages/autocomplete-clang
[18]: https://github.com/Andersbakken/rtags#integration-with-systemd-gnu-linux
