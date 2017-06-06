#!/bin/bash
set -e

# Load entrypoint script from parent image
# ARGS=("$@")
# set --
# TODO: find a better way to handle $@ passing that does not require
#       any edits to the parent's script
IS_SOURCED=1
source /usr/sbin/entrypoint.sh

# Setup the custom bashrc
echo "Including an additional bashrc configuration"
# -colors
cp /usr/etc/skel/bashrc-colors /home/$USERNAME/.bashrc-colors
chown ${USERNAME}:${USERNAME} /home/$USERNAME/.bashrc-colors
echo "source /home/$USERNAME/.bashrc-colors" >> /home/${USERNAME}/.bashrc
echo "source /home/$USERNAME/.bashrc-colors" >> /root/.bashrc
# -dev
cp /usr/etc/skel/bashrc-dev /home/$USERNAME/.bashrc-dev
chown ${USERNAME}:${USERNAME} /home/$USERNAME/.bashrc-dev
echo "source /home/$USERNAME/.bashrc-dev" >> /home/${USERNAME}/.bashrc
echo "source /home/$USERNAME/.bashrc-dev" >> /root/.bashrc

# Mount the project directory
if [[ -n ${PROJECT_DIR} && -d "/home/$USERNAME/$(basename ${PROJECT_DIR})" ]] ; then
	chown -R $USERNAME:$USERNAME /home/$USERNAME/"$(basename ${PROJECT_DIR})"
fi

# Use persistent bash_history file
if [ -e "/home/$USERNAME/.bash_history" ] ; then
	chown $USERNAME:$USERNAME /home/$USERNAME/.bash_history
fi

# Configure git
if [[ ! -z ${GIT_USER_NAME:+x} && ! -z ${GIT_USER_EMAIL:+x} ]] ; then
	echo "Setting up git ..."
	su -c "git config --global user.name ${GIT_USER_NAME}" $USERNAME
	su -c "git config --global user.email ${GIT_USER_EMAIL}" $USERNAME
	su -c "git config --global color.pager true" $USERNAME
	su -c "git config --global color.ui auto" $USERNAME
	su -c "git config --global push.default upstream" $USERNAME
	if [[ "${GIT_USE_GPG}" = "1" && -n "${GIT_GPG_KEY}" ]] ; then
    su -c "export GPG_TTY=$(tty)" $USERNAME
		su -c "git config --global commit.gpgsign true" $USERNAME
		su -c "git config --global gpg.program gpg2" $USERNAME
		su -c "git config --global user.signingkey ${GIT_GPG_KEY}" $USERNAME
	fi
	echo "... Done"
fi

# Fix permissions of the IIT directory and link it into the user's home
if [ -d ${IIT_DIR} ] ; then
	chown -R $USERNAME:$USERNAME ${IIT_DIR}
	if [ ! -d /home/$USERNAME/$IIT_DIR ] ; then
		su -c "ln -s ${IIT_DIR} /home/$USERNAME/$IIT_DIR" $USERNAME
	fi
fi

if [ -d "/home/$USERNAME/.ccache" ] ; then
	chown -R $USERNAME:$USERNAME /home/$USERNAME/.ccache
fi

# Configure YARP namespace
if [ -n "${YARP_NAME_SPACE}" ] ; then
	su -c 'eval "${IIT_INSTALL}/bin/yarp namespace ${YARP_NAME_SPACE}"' $USERNAME
fi

# Setup ROS environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
exec "$@"
