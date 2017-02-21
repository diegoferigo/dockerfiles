# Colors, colors, colors
if [ $UID -ne 0 ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\e[32;1m\]\u\[\e[0m\]@\H:\[\033[01;34m\]\w\e[0m\]\[\033[00;32m\]$(__git_ps1 " (%s)")\e[0m\]$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\[\e[31;1m\]\u\[\e[0m\]@\H:\[\033[01;34m\]\w\e[0m\]# '
fi

# Update the PATH
PATH=${IIT_PATH:+${IIT_PATH}:}$PATH

# Load the ROS environment
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

# History handling
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Mappings for Ctrl-left-arrow and Ctrl-right-arrow for words navigation
bind '"\e[1;5C": forward-word'
bind '"\e[1;5D": backward-word'
bind '"\e[5C": forward-word'
bind '"\e[5D": backward-word'
bind '"\e\e[C": forward-word'
bind '"\e\e[D": backward-word'
