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

# Load the default ROS entrypoint
source /ros_entrypoint.sh
