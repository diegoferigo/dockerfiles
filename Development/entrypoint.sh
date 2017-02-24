#!/bin/bash
set -e

# These variables can be overridden by docker environment variables
USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}
USERNAME=${USERNAME:-docker}

create_user() {
	# If the home folder exists, set a flag.
	# Creating the user during container initialization often is anticipated
	# by the mount of a docker volume. In this case the home directory is already
	# present in the file system and adduser skips by default the copy of the
	# configuration files
	HOME_FOLDER_EXISTS=0
	if [ -d /home/$USERNAME ] ; then HOME_FOLDER_EXISTS=1 ; fi

	# Create a group with USER_GID
	if ! getent group ${USERNAME} >/dev/null; then
		echo "Creating ${USERNAME} group"
		groupadd -f -g ${USER_GID} ${USERNAME} 2> /dev/null
	fi

	# Create a user with USER_UID
	if ! getent passwd ${USERNAME} >/dev/null; then
		echo "Creating ${USERNAME} user"
		adduser --quiet \
		        --disabled-login \
				  --uid ${USER_UID} \
				  --gid ${USER_GID} \
				  --gecos 'Workspace' \
				  ${USERNAME}
	fi

	# If configuration files have not been copied, do it manually
	if [ HOME_FOLDER_EXISTS ] ; then
		chown ${USER_UID}:${USER_GID} /home/${USERNAME}
		install -m 644 -g ${USERNAME} -o ${USERNAME} /etc/skel/.bashrc /home/${USERNAME}
		install -m 644 -g ${USERNAME} -o ${USERNAME} /etc/skel/.bash_logout /home/${USERNAME}
		install -m 644 -g ${USERNAME} -o ${USERNAME} /etc/skel/.profile /home/${USERNAME}
	fi
}

# Create the user
create_user

# Setup the custom bashrc
echo "Including an additional bashrc configuration"
cp /usr/etc/skel/bashrc-dev /home/$USERNAME/.bashrc-dev
chown ${USERNAME}:${USERNAME} /home/$USERNAME/.bashrc-dev
echo "source /home/$USERNAME/.bashrc-dev" >> /home/${USERNAME}/.bashrc
echo "source /home/$USERNAME/.bashrc-dev" >> /root/.bashrc

# Add the user to video group for HW acceleration (only Intel cards supported)
usermod -aG video ${USERNAME}

# Mount the project directory
if [ -d "/home/$USERNAME/$(basename ${PROJECT_DIR})" ] ; then
	chown -R $USERNAME:$USERNAME /home/$USERNAME/$(basename ${PROJECT_DIR})
fi

# Use persistent bash_history file
if [ -e "/home/$USERNAME/.bash_history" ] ; then
	chown $USERNAME:$USERNAME /home/$USERNAME/.bash_history
fi

# Move Atom packages to the user's home
# This command should work even if ~/.atom is mounted as volume from the host,
# and it should comply the presence of an existing ~/.atom/packages/ folder
COPY_ATOM_PACKAGES=${COPY_ATOM_PACKAGES:-0}
if [[ ${COPY_ATOM_PACKAGES} -eq 1 && -d "/root/.atom" ]] ; then
	echo "Setting up Atom packages into $USERNAME's home ..."
	if [ -d "/home/$USERNAME/.atom_packages_from_root" ] ; then
		rm -r "/home/$USERNAME/.atom_packages_from_root"
	fi
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
	cd /
	echo "... Done"
fi

# Configure git
if [[ ! -z ${GIT_USER_NAME:+x} && ! -z ${GIT_USER_EMAIL:+x} ]] ; then
	echo "Setting up git ..."
	su -c "git config --global user.name ${GIT_USER_NAME}" $USERNAME
	su -c "git config --global user.email ${GIT_USER_EMAIL}" $USERNAME
	su -c "git config --global color.pager true" $USERNAME
	su -c "git config --global color.ui auto" $USERNAME
	su -c "git config --global push.default upstream" $USERNAME
	echo "... Done"
fi

# Move the ccache folder into the user's home
if [[ -d /root/.ccache && ! -d "/home/$USERNAME/.ccache" ]] ; then
	echo "Moving ccache directory"
	mv /root/.ccache /home/$USERNAME/.ccache
	chown -R $USERNAME:$USERNAME /home/$USERNAME/.ccache
fi

# Fix permissions of the IIT directory and link it into the user's home
if [ -d ${IIT_DIR} ] ; then
	chown -R $USERNAME:$USERNAME ${IIT_DIR}
	su -c "ln -s ${IIT_DIR} /home/$USERNAME/$IIT_DIR" $USERNAME
fi

# Configure YARP namespace and connect to the server
if [ -n "${YARP_NAME_SPACE}" ] ; then
	su -c 'eval "${IIT_INSTALL}/bin/yarp namespace ${YARP_NAME_SPACE}"' $USERNAME
	su -c '${IIT_INSTALL}/bin/yarp detect --write' $USERNAME
fi

# Load the default ROS entrypoint
source /ros_entrypoint.sh
