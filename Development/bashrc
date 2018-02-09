# Colors, colors, colors
if [ $UID -ne 0 ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\e[36;1m\]\u\[\e[0m\]@\H:\[\e[30;1m\]\w\[\e[0m\]\[\e[00;36m\]$(__git_ps1 " (%s)")\[\e[36;1m\]>\[\e[0m\]\[\e[1m\] '
else
	PS1='${debian_chroot:+($debian_chroot)}\[\e[31;1m\]\u\[\e[0m\]@\H:\[\e[30;1m\]\w\[\e[31;1m\]#\[\e[0m\]\[\e[1m\] '
fi

# After changing user, cd inside $HOME. Use $(cd -) to get back to the previous folder
cd $HOME || return 1

# Configuration of the bash environment
# =====================================

# Reset PS1 color before command's output
trap 'echo -ne "\e[0m"' DEBUG

# Disable echo ^C when Ctrl+C is pressed
stty -echoctl

# Avoid using cd to change directory. Simply: ~# /etc
shopt -s autocd

# Case insensitive filename completion
shopt -s nocaseglob

# Autocorrect simple typos
shopt -s cdspell
shopt -s dirspell direxpand

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

# Disable completion when the input buffer is empty.  i.e. Hitting tab
# and waiting a long time for bash to expand all of $PATH.
shopt -s no_empty_cmd_completion

# History handling
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
shopt -s histappend
PROMPT_COMMAND='history -a'

# Mappings for Ctrl-left-arrow and Ctrl-right-arrow for words navigation
bind '"\e[1;5C": forward-word'
bind '"\e[1;5D": backward-word'
bind '"\e[5C": forward-word'
bind '"\e[5D": backward-word'
bind '"\e\e[C": forward-word'
bind '"\e\e[D": backward-word'

# Configuration of frameworks and tools
# =====================================

# Explicitly enable gcc colored output
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Set the default editor
if [ -e $(which nano) ] ; then
	export EDITOR="nano"
	echo "include /usr/share/nano/*" > ~/.nanorc
fi

# Load the robotogy-superbuild environment
if [[ -e ${IIT_SOURCES}/robotology-superbuild/build/install/share/robotology-superbuild/setup.sh && -z $SUPERBUILD_SOURCED ]] ; then
    source ${IIT_SOURCES}/robotology-superbuild/build/install/share/robotology-superbuild/setup.sh
    export SUPERBUILD_SOURCED=1
fi

# Load the ROS environment
if [ -e /opt/ros/$ROS_DISTRO/setup.bash ] ; then
    source /opt/ros/$ROS_DISTRO/setup.bash
fi

# Load the gazebo environment
if [ -e /usr/share/gazebo/setup.sh ] ; then
    source /usr/share/gazebo/setup.sh
fi

# Docker configures the path of the root user. Set here the PATH also for the runtime user
export PATH=${IIT_PATH:+${IIT_PATH}:}${PATH}:/opt/qtcreator/bin

# Enable ccache for the user created during runtime
if [ -x $(which ccache) ] ; then
	export PATH=/usr/lib/ccache:${PATH}
fi

# If clang is installed, use it as default compiler
if [[ -x $(which clang-${CLANG_VER}) && -x $(which clang++-${CLANG_VER}) ]] ; then
	export CC="clang-${CLANG_VER}"
	export CXX="clang++-${CLANG_VER}"
fi

# Enable matlab
if [ -x "/usr/local/MATLAB/bin/matlab" ] ; then
	export PATH=${PATH}:/usr/local/MATLAB/bin
	export MATLABPATH=${ROBOTOLOGY_SUPERBUILD_INSTALL_PREFIX}/mex/:${ROBOTOLOGY_SUPERBUILD_INSTALL_PREFIX}/share/WB-Toolbox/:${ROBOTOLOGY_SUPERBUILD_INSTALL_PREFIX}/share/WB-Toolbox/images
	# https://github.com/robotology/WB-Toolbox#problems-finding-libraries-and-libstdc
	alias matlab="LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 matlab"
	# Set the bindings up
	export MATLABPATH=${MATLABPATH}:${IIT_INSTALL}/matlab
fi

# Aliases
# =======

NANO_DEFAULT_FLAGS="-w -S -i -m -$"
CMAKE_DEFAULT_FLAGS="--warn-uninitialized -DCMAKE_EXPORT_COMPILE_COMMANDS=1"
alias nano='nano $NANO_DEFAULT_FLAGS'
alias nanos='nano $NANO_DEFAULT_FLAGS -Y sh'
alias cmake='cmake $CMAKE_DEFAULT_FLAGS'
alias glog='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
if [ -e $(which pygmentize) ] ; then
	alias ccat='pygmentize -g'
	alias lesc='LESS="-R" LESSOPEN="|pygmentize -g %s" less'
	export LESS='-R'
	export LESSOPEN='|pygmentize -g %s'
fi
if [ -e $(which valgrind) ] ; then
	alias valgrind-xml='valgrind --xml=yes --xml-file=/tmp/valgrind.log'
	if [ -e $(which colour-valgrind) ] ; then
		alias valgrind='colour-valgrind'
	fi
fi
if [ -e $(which colordiff) ] ; then
	alias diff='colordiff'
fi
if [ -e $(which octave) ] ; then
	OCTAVE_BINDINGS_ROOT="${IIT_INSTALL}/octave"
	OCTAVE_BINDINGS_DIRS=""
	for extra_bindings_dir in ${OCTAVE_BINDINGS_ROOT}/+* ; do
		if [ -d ${extra_bindings_dir} ] ; then
			OCTAVE_BINDINGS_DIRS+="-p ${extra_bindings_dir} "
		fi
	done
	alias octave='octave -p ${OCTAVE_BINDINGS_ROOT} ${OCTAVE_BINDINGS_DIRS}'
fi
if [ -e $(which gazebo) ] ; then
	alias gazebo='gazebo -u'
fi

# Utility functions
# =================

msg() {
	echo -e "$BGreen==>$Color_Off $1"
}

msg2() {
	echo -e "  $BBlue->$Color_Off $1"
}

err() {
	echo -e "$BRed==>$Color_Off $1"
}

function mkdircd() {
	if [ ! -d  $1 ] ; then
		mkdir -p $1
		cd $1 || return 1
	fi
}

# cd and ls in one
function cl() {
	dir=$1
	if [[ -d "$dir" ]] ; then
		cd "$dir"
		ls
	else
		err "cl: '$dir': Directory not found"
	fi
}

# Start and configure yarp
function yarpinit() {
	if [[ -n "${YARP_NAME_SPACE}" || -n "$1" ]] ; then
		if [ -n "${YARP_NAME_SPACE}" ] ; then
			Y_NAMESPACE=${YARP_NAME_SPACE}
		else
			Y_NAMESPACE="$1"
		fi
		msg "Setting the YARP namespace"
		eval "yarp namespace ${Y_NAMESPACE}"
		# If no yarp server is running, spawn a new instance
		msg "Detecting YARP..."
		yarp detect &>/dev/null
		if [ $? -ne 0 ] ; then
			msg2 "YARP is not running"
			msg2 "Spawning a new yarpserver"
			yarpserver --write &
			sleep 2
		else
			msg2 "YARP is already running"
		fi
		msg "Storing the configuration of the server"
		yarp detect --write &>/dev/null || return 1
	else
		err "No yarp namespace is set. Export a YARP_NAME_SPACE env variable or pass it as $1"
	fi
}

# Configure a CMake project while performing additional operations on files used by the
# the development toolchain. This function accepts `cmake` or `ccmake` as input argument.
function cm_template() {
	msg "Starting the build process"
	if [ -e CMakeLists.txt ] ; then
		msg2 "CMakeLists.txt found"
		if [ -e build/CMakeCache.txt ] ; then
			msg2 "Using CMake cache"
		else
			msg2 "Creating new build folder"
			mkdir -p build/
		fi
		cd build  || return 1
		# Execute cmake or ccmake. You can pass additional cmake flags and they'll be included
		BINARY=$1
		shift 1
		msg "Executing ${BINARY}"
		${BINARY} .. \
		          --warn-uninitialized \
		          -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
		          "$@"
		# Copy the compilation database to the project's root (required by linter-clang).
		# autocomplete-clang instead needs the file to be in the build/ directory
		cd ..
		if [ -e build/compile_commands.json ] ; then
			msg "IDE configuration"
			msg2 "Generating the compile_commands.json file"
			cp build/compile_commands.json compile_commands.json
		else
			err "File compile_commands.json not found"
		fi
	else
		err "CMakeLists.txt not found in this folder"
		return 1
	fi
	msg "Done"
}

# Custom execution of c(c)make + make
function cmm_template() {
	cm_template "$@"
	cd build || return 1
	# Build the sources
	make -j ${GCC_JOBS}
	cd ..
}

# Custom execution of c(c)make + make + make install
function cmi_template() {
	cmm_template "$@"
	cd build || return 1
	# Install the sources
	make install
	cd ..
}

# Use the _template function with `cmake`
function cm() {
	cm_template cmake "$@"
}
function cmm() {
	cmm_template cmake "$@"
}
function cmi() {
	cmi_template cmake "$@"
}

# Use the _template function with `ccmake`
function ccm() {
	cm_template ccmake "$@"
}
function ccmm() {
	cmm_template ccmake "$@"
}
function ccmi() {
	cmi_template ccmake "$@"
}

# Custom execution of cmake + make + make install into ${IIT_DIR}
function cmiit() {
	cmi -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} "$@"
}
function ccmiit() {
	ccmi -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} "$@"
}

# Function to switch gcc/clang compiler
function compiler.set() {
		case $1 in
			gcc|1)
				msg "Setting gcc"
				export CC="gcc"   && export CXX="g++" ;;
			clang${CLANG_VER%.*}|2)
			msg "Setting clang${CLANG_VER%.*}"
				export CC="clang-${CLANG_VER}" && export CXX="clang++-${CLANG_VER}" ;;
			*) err "$1: only gcc and clang are supported compilers" ; return 1 ;;
		esac
		return 0
}

function compiler.get() {
	if [[ "$CC" = "gcc" && "$CXX" = "g++" ]] ; then
		msg "The active compiler is: gcc"
		return 1
	elif [[ "$CC" = "clang-${CLANG_VER}" && "$CXX" = "clang++-${CLANG_VER}" ]] ; then
		msg "The active compiler is: clang-${CLANG_VER}"
		return 2
	else
		err "The compiler environment variables aren't set."
		return 3
	fi
}

function compiler.switch() {
	compiler.get
	case $? in
		1) compiler.set 2 ;;
		2) compiler.set 1 ;;
		*) compiler.set 2 ;;
	esac
}

# Since the codyco-superbuild is not installed, it could be useful having the possibility
# of storing a second tree of sources somewhere else and configure the environment to find it
# instead of the original one
function setlocalcodyco () {
	if [[ ! -n "$1" || ! -e "$1" ]] ; then
		err "Folder not found $1"
		if [[ -n "$CODYCO_SUPERBUILD_ROOT" ]] ; then
			msg2 "The current CODYCO_SUPERBUILD_ROOT is $CODYCO_SUPERBUILD_ROOT"
		fi
		return 1
	elif [[ ! -n "$CODYCO_SUPERBUILD_ROOT" ]] ; then
		err "The variable CODYCO_SUPERBUILD_ROOT is not set"
		return 1
	else
		readarray CODYCO_ENV_VARS < <(env | grep ${CODYCO_SUPERBUILD_ROOT} | sed "s|${CODYCO_SUPERBUILD_ROOT}|${1%/}|g")
		for ENV_VAR in ${CODYCO_ENV_VARS[*]} ; do
			export $ENV_VAR
		done
	fi
}

# Matlab support is still rough. Some software compiled while creating the image may have
# components that depend on Matlab. Considering that there is no easy way to share a local
# copy of Matlab during for creating the image, those components are explicitly disabled.
# This function, that must be kept aligned with the development of the Dockerfile,
# sets up all the variables that enable matlab support.
# After running this function, copying and pasting the cmake command line should be sufficient
# to enable all the matlab and simulink flags.
function enable_matlab() {
	export ROBOTOLOGY_USES_MATLAB=ON
	export ROBOTOLOGY_GENERATE_MEX=ON
}
