#!/bin/bash

# SCRIPT SETUP
# ============

set -o errexit
set -o nounset

# Exit Codes
EC_NOOP=2
EC_DOCKERCOMPOSE_NOTFOUND=3
EC_DOCKERCOMPOSE=4
EC_ENV_NOTFOUND=5

# LOAD .env FILE
# ==============

if [ -e $(pwd)/.env ] ; then
	source .env
else
	err ".env file not found!"
	exit $EC_ENV_NOTFOUND
fi

# CONSTANTS
# =========
readonly PROJECT_DIR_DEFAULT="/tmp/docker-tmpfolder"
declare -a PERSISTENT_FILES
declare -a PERSISTENT_FOLDERS
PERSISTENT_FILES=($HOST_BASH_HISTORY_FILE)
PERSISTENT_FOLDERS=($HOST_CCACHE_DIR
                    $HOST_ATOM_DOT_DIR \
                    $HOST_ATOM_CONF_DIR \
                    $HOST_QTCREATOR_CONF_DIR \
                    $HOST_MATLAB_DOT_DIR \
                    $HOST_GITKRAKEN_DOT_DIR \
                    $HOST_YARPLOCAL_DIR)

# UTILITY FUNCTIONS AND VARIABLES
# ===============================

Color_Off='\e[0m'
BRed='\e[1;31m'
BBlue='\e[1;34m'
BGreen='\e[1;32m'

function msg()
{
	echo -e "$BGreen==>$Color_Off $1"
}

function msg2()
{
	echo -e "  $BBlue->$Color_Off $1"
}

function err()
{
	echo -e "$BRed==>$Color_Off $1"
}

function err2()
{
	echo -e "  $BRed==>$Color_Off $1"
}

function print_help()
{
	echo "Usage: $0 [OPTIONS] ... [COMMAND]"
	echo
	echo "Helper script for spawning containers used as development setup"
	echo
	echo "Commands:"
	echo
	echo "  start|up    Start the composed setup"
	echo "  stop|down   Stop the composed setup"
	echo
	echo "Optional arguments:"
	echo "  -p    Project directory mounted in the HOME (default: /tmp/docker-tmpfolder)"
	echo
	echo "Examples:"
	echo "$0 -p /home/user/git/myproject start"
	echo
	echo "Diego Ferigo: <diego.ferigo@iit.it>"
	echo "iCub Facility - Italian Institute of Technology"
}

# FUNCTIONS
# =========

function find_docker_bin()
{
	msg "Finding the docker-compose binary"
	if [ -x $(which nvidia-docker-compose) ] ; then
		DOCKERCOMPOSE_BIN=$(which nvidia-docker-compose)
	elif [ -x $(which docker-compose) ] ; then
		DOCKERCOMPOSE_BIN=$(which docker-compose)
	else
		err "Docker compose not found! Check your \$PATH"
		exit $EC_DOCKERCOMPOSE_NOTFOUND
	fi
	msg2 "Using $DOCKERCOMPOSE_BIN"
}

function handle_persistent_resources()
{
	# Persistent files
	for file in "${PERSISTENT_FILES[@]}" ; do
		if [ ! -f $file ] ; then
			touch $file || (err2 "Unable to create $file" && exit 1)
		fi
	done

	# Persistent folders
	for folder in "${PERSISTENT_FOLDERS[@]}" ; do
		if [ ! -d $folder ] ; then
			mkdir -p $folder || (err2 "Unable to create $folder" && exit 1)
		fi
	done
}

function docker_workspace()
{
	case $1 in
		start|up)
			msg "Starting up..."
			# Set the X11 authentication resources
			msg "Setting up X11 resources"
			if [ ! -e $XAUTH ] ; then
				msg2 "Creating authentication file"
				touch $XAUTH
				chmod 777 $XAUTH
			else
				msg2 "X11 authentication file found"
			fi
			msg2 "Granting X11 permissions"
			xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

			msg "Setting up the project's resources"
			# If a folder is passed as $2, mount it into the host and set it as
			# working directory
			if [[ -z ${2:+x} || ! -d $2 ]] ; then
				msg2 "The project folder does not exist. Using \"${PROJECT_DIR_DEFAULT}\""
				PROJECT_DIR=${PROJECT_DIR_DEFAULT}
			else
				msg2 "Project folder: $2"
				PROJECT_DIR=$2
			fi

			# Create the persistent bash history file if not already present
			# This is needed because otherwise docker will create a directory
			# instead of a text file
			msg "Handling persistent resources"
			handle_persistent_resources

			# Compose the workspace containers
			msg "Composing the containers"
			PROJECT_DIR=$PROJECT_DIR \
			PROJECT_BASENAME=$(basename $PROJECT_DIR) \
			$DOCKERCOMPOSE_BIN up -d || exit $EC_DOCKERCOMPOSE
			;;
		stop|down)
			msg "Stopping..."
			# Stop and remove the composed containers
			if [ -e ${XAUTH} ] ; then
				msg2 "Deleting the X11 authentication file"
				rm -r ${XAUTH}
			fi
			msg2 "Removing the containers"
			$DOCKERCOMPOSE_BIN down || exit $EC_DOCKERCOMPOSE
			;;
		*)
			err "$1: command not found"
			echo
			print_help
			exit $EC_NOOP
			;;
	 esac
}

# MAIN
# ====

# Parse cmdline
while getopts :p: OPT ; do
	case $OPT in
	p)
		IN_OPT_WDIR=$OPTARG
		;;
	\?)
		print_help
		exit $EC_NOOP
		;;
	esac
done
IN_OPT_WDIR=${IN_OPT_WDIR:-" "}

# Get the last parameter(s), i.e. the command to execute
shift $((OPTIND - 1))
COMMAND="$@"

find_docker_bin
docker_workspace $COMMAND $IN_OPT_WDIR
