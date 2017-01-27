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

# Move Atom packages to the user's home
# This command should work even in ~/.atom is mounted as volume from the host,
# and it should comply the presence of an existing ~/.atom/packages/ folder
echo "Setting up Atom packages into $USERNAME's home ..."
mv /root/.atom /home/$USERNAME/.atom_packages_from_root
chown -R $USERNAME:$USERNAME /home/$USERNAME/.atom_packages_from_root
declare -a ATOM_PACKAGES
ATOM_PACKAGES=($(find /home/$USERNAME/.atom_packages_from_root/packages -mindepth 1 -maxdepth 1 -type d))
for package in ${ATOM_PACKAGES[@]} ; do
	cd $package
	su -c "apm link" $USERNAME >/dev/null
done
cd
echo "Done ..."

# If a CMD is passed, execute it
exec "$@"
