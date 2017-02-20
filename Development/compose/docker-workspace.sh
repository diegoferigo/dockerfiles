#!/bin/bash

# Variables loaded from .env
source .env

docker-workspace() {
	 case $1 in
		  start|up)
				# Set the X11 authentication resources
				if [ ! -e $XAUTH ] ; then
					 echo "=> Creating authentication file"
					 touch $XAUTH
					 chmod 777 $XAUTH
				fi
				echo "=> Granting X11 permissions"
				xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

				# If a folder is passed as $2, mount it into the host and set it as
				# working directory
				if [ ! -z ${2:+x} ] ; then # $2 is not empty
					if  [ -d $2 ] ; then # $2 is an existing folder
						PROJECT_DIR=$2
					fi
				fi

				# If unset, mount a temporary folder
				PROJECT_DIR=${PROJECT_DIR:-"/tmp/docker-tmpfolder"}

				# Compose the workspace containers
				echo "=> Composing the containers"
				PROJECT_DIR=$PROJECT_DIR docker-compose up -d
		  ;;
		  stop|down)
				# Stop and remove the composed containers
				echo "=> Removing the containers"
				if [ -e ${XAUTH} ] ; then
					 rm -r ${XAUTH}
				fi
				docker-compose down
		  ;;
		  status) # TODO: show the status of the composed system
		  ;;
		  *) ;;
	 esac
}

docker-workspace $1 $2
