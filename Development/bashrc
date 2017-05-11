# Colors, colors, colors
if [ $UID -ne 0 ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\e[36;1m\]\u\[\e[0m\]@\H:\[\e[30;1m\]\w\[\e[0m\]\[\e[00;36m\]$(__git_ps1 " (%s)")\[\e[36;1m\]>\[\e[0m\]\[\e[1m\] '
else
	PS1='${debian_chroot:+($debian_chroot)}\[\e[31;1m\]\u\[\e[0m\]@\H:\[\e[30;1m\]\w\[\e[31;1m\]#\[\e[0m\]\[\e[1m\] '
fi

# After changing user, cd inside $HOME. Use $(cd -) to get back to the previous folder
cd $HOME || return 1

# Reset PS1 color before command's output
trap 'echo -ne "\e[0m"' DEBUG

# Update the PATH
PATH=/usr/lib/ccache:${IIT_PATH:+${IIT_PATH}:}$PATH

# Load the ROS environment
# shellcheck source=/opt/ros/$ROS_DISTRO/setup.bash
source "/opt/ros/$ROS_DISTRO/setup.bash"

# Load the gazebo environment
source /usr/share/gazebo/setup.sh

# Disable echo ^C when Ctrl+C is pressed
stty -echoctl

# Set the default editor
export EDITOR="nano"

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

# Explicitly enable gcc colored output
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Aliases
NANO_FLAGS="-w -S -i -m -$"
alias nano='nano $NANO_FLAGS'
alias nanos='nano $NANO_FLAGS -Y sh'
alias cmake='cmake --warn-uninitialized -DCMAKE_EXPORT_COMPILE_COMMANDS=1'
if [ -e $(which pygmentize) ] ; then
	alias ccat='pygmentize -g'
	alias lesc='LESS="-R" LESSOPEN="|pygmentize -g %s" less'
	export LESS='-R'
	export LESSOPEN='|pygmentize -g %s'
fi

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
		echo "cl: '$dir': Directory not found"
	fi
}

# Configure a CMake project while performing additional operations on files used by the
# the development toolchain. This function accepts `cmake` or `ccmake` as input argument.
function cm_template() {
	if [ -e CMakeLists.txt ] ; then
		# If build/ exists, remove it
		if [[ -d build/ && $1 != "ccmake" ]] ; then
			rm -r build/
			mkdir build
		fi
		cd build  || return 1
		# Execute cmake or ccmake. You can pass additional cmake flags and they'll be included
		BINARY=$1
		shift 1
		$BINARY .. \
		        --warn-uninitialized \
		        -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
		        "$@"
		# Copy the compilation database to the project's root (required by linter-clang).
		# autocomplete-clang instead needs the file to be in the build/ directory
		cd ..
		if [ -e build/compile_commands.json ] ; then
			cp build/compile_commands.json compile_commands.json
		else
			echo "File compile_commands.json not found"
		fi
		# If rmd is not running, execute it
		if [ ! "$(ps ax | tr -s " " | cut -d " " -f 6 | grep rdm)" = "rdm" ] ; then
			echo "-- rdm is not running. Spawning a process"
			rdm --daemon
			sleep 1
		fi
		# Send to rdm the compilation database
		if [ -e build/compile_commands.json ] ; then
			rc -J >/dev/null
		fi
	fi
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
	if [[ "$1" = "gcc" || "$1" = "clang" ]] ; then
		case $1 in
			gcc)   export CC="gcc"   && export CXX="g++"     ;;
			clang) export CC="clang" && export CXX="clang++" ;;
		esac
	else
		echo "$1: only gcc and clang are supported compilers"
		return 1
	fi
}

function compiler.get() {
	if [[ "$CC" = "gcc" && "$CXX" = "g++" ]] ; then
		echo "The active compiler is: gcc"
		return 1
	elif [[ "$CC" = "clang" && "$CXX" = "clang++" ]] ; then
		echo "The active compiler is: clang"
		return 2
	else
		echo "The compiler environment variables aren't set"
		return 2
	fi
}

function compiler.switch() {
	# echo compiler.get
	compiler.get
    case $? in
    	1) echo "Switching to: clang" ; compiler.set clang ;;
    	2) echo "Switching to: gcc"   ;  compiler.set gcc  ;;
    	*) echo "Compiler not set. Setting gcc." ; compiler.set gcc ;;
    esac
}
