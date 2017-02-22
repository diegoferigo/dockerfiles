# Colors, colors, colors
if [ $UID -ne 0 ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\e[32;1m\]\u\[\e[0m\]@\H:\[\033[01;34m\]\w\e[0m\]\[\033[00;32m\]$(__git_ps1 " (%s)")\e[0m\]$ \e[1m\]'
else
	PS1='${debian_chroot:+($debian_chroot)}\[\e[31;1m\]\u\[\e[0m\]@\H:\[\033[01;34m\]\w\e[0m\]# \e[1m\]'
fi

# Reset PS1 color before command's output
trap 'echo -ne "\e[0m"' DEBUG

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
