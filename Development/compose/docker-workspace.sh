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

            # Compose the workspace containers
            echo "=> Composing the containers"
            docker-compose up -d
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

docker-workspace $1
