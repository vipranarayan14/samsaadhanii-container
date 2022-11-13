#!/bin/sh
set -e
# Note: This is written using sh so it works in the busybox container too.

# USE the trap if you need to also do manual cleanup after the service is stopped,
#     or need to start multiple services in the one container
trap "echo TRAPed signal" HUP INT QUIT TERM

if [ "$1" = "start-server" ]; then
    apachectl start

    echo "Running server... Open http://localhost[:PORT]/scl/ in your browser.\n"
    echo "Hit 'Enter' key to exit or run 'docker stop <container>'"
    read enter

    echo "Stopping server"
    apachectl stop
else
    exec $@
fi