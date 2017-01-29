#!/bin/bash
set -e

# These variables can be overridden by docker environment variables
USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}
USERNAME=${USERNAME:-docker}

create_user() {
	# If the home folder exists, copy inside the default files of a home directory
	if [ -d /home/${USERNAME} ] ; then
		chown ${USER_UID}:${USER_GID} /home/${USERNAME}
		install -m 644 -g ${USERNAME} -o ${USERNAME} /etc/skel/.bashrc /home/${USERNAME}
		install -m 644 -g ${USERNAME} -o ${USERNAME} /etc/skel/.bash_logout /home/${USERNAME}
		install -m 644 -g ${USERNAME} -o ${USERNAME} /etc/skel/.profile /home/${USERNAME}
	fi

	# Create a group with USER_GID
	if ! getent group ${USERNAME} >/dev/null; then
		groupadd -f -g ${USER_GID} ${USERNAME} 2> /dev/null
	fi

	# Create a user with USER_UID
	if ! getent passwd ${USERNAME} >/dev/null; then
		adduser --disabled-login --uid ${USER_UID} --gid ${USER_GID} --gecos 'Workspace' ${USERNAME}
	fi
}

# Create the user
create_user

# Add the user to video group for HW acceleration (only Intel cards supported)
usermod -aG video ${USERNAME}

# There is a weird issue when mounting the ~/.atom and ~/.gitkraken folders.
# The user is created during runtime by this script. The folders are mounted by
# docker supposedly before the execution of this script. However, I get a strange
# > install: invalid user diego
# if I try to mount them with `docker run`.
# It seems that "-e $USERNAME" and "-v $HOME/.atom:/home/${USERNAME}/.atom" create
# a sort of conflict.
# For the time being, solve this problem with symlinks.
# TODO: fix configuration folders mounting issues
if [ -d "/home/conf/.gitkraken" ] ; then
	chown -R $USERNAME:$USERNAME /home/conf/.gitkraken
	su -c "ln -s /home/conf/.gitkraken /home/$USERNAME/.gitkraken" $USERNAME
fi
if [ -d "/home/conf/.atom" ] ; then
	chown -R $USERNAME:$USERNAME /home/conf/.atom
	su -c "ln -s /home/conf/.atom /home/$USERNAME/.atom" $USERNAME
fi

# Move Atom packages to the user's home
# This command should work even if ~/.atom is mounted as volume from the host,
# and it should comply the presence of an existing ~/.atom/packages/ folder
COPY_ATOM_CONF=${COPY_ATOM_CONF:-0}
if [ ${COPY_ATOM_CONF} -eq 1 ] ; then
	echo "Setting up Atom packages into $USERNAME's home ..."
	mv /root/.atom /home/$USERNAME/.atom_packages_from_root
	chown -R $USERNAME:$USERNAME /home/$USERNAME/.atom_packages_from_root
	declare -a ATOM_PACKAGES
	ATOM_PACKAGES=($(find /home/$USERNAME/.atom_packages_from_root/packages -mindepth 1 -maxdepth 1 -type d))
	for package in ${ATOM_PACKAGES[@]} ; do
		if [ ! -e /home/$USERNAME/.atom/packages/$(basename $package) ] ; then
			cd $package
			su -c "apm link" $USERNAME
		fi
	done
	cd
	echo "Done ..."
fi

# Load the default ROS entrypoint
source /ros_entrypoint.sh
