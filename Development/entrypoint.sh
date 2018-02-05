#!/bin/bash
set -e

if [ -z "$(which setup_development.sh)" ] ; then
    echo "File setup_development.sh not found."
    exit 1
fi

setup_development.sh

# If a CMD is passed, execute it
exec "$@"
