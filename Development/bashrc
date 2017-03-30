# Colors, colors, colors
if [ $UID -ne 0 ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\e[32;1m\]\u\[\e[0m\]@\H:\[\033[01;34m\]\w\e[0m\]\[\033[00;32m\]$(__git_ps1 " (%s)")\e[0m\]$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\[\e[31;1m\]\u\[\e[0m\]@\H:\[\033[01;34m\]\w\e[0m\]# '
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
alias cmake='cmake --warn-uninitialized -DCMAKE_EXPORT_COMPILE_COMMANDS=1'
alias cmakeiit='cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL}'
if [ -e $(which pygmentize) ] ; then
	alias ccat="pygmentize -g"
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

function cm() {
	if [ -e CMakeLists.txt ] ; then
		# If build/ exists, remove it
		if [ -d build/ ] ; then
			rm -r build/
		fi
		# Create an empty build dir and cd inside
		mkdir build
		cd build  || return 1
		# Execute cmake. You can pass additional cmake flags and they'll be included
		cmake .. \
		      --warn-uninitialized \
			  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
			  "$@"
		# Copy the compilation database to the project's root (required by linter-clang).
		# autocomplete-clang instead needs the file to be in the build/ directory
		cd ..
		if [ -e build/compile_commands.json ] ; then
			cp build/compile_commands.json .
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

# Custom execution of cmake + make
function cmm() {
	cm "$@"
	cd build || return 1
	# Build the sources
	make -j ${GCC_JOBS}
	cd ..
}

# Custom execution of cmake + make + make install
function cmi() {
	cmm "$@"
	cd build || return 1
	# Install the sources
	make install
	cd ..
}

# Custom execution of cmake + make + make install into ${IIT_DIR}
function cmiit() {
	cmi -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL}
}
