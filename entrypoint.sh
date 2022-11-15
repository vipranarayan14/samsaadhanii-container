#!/bin/bash

# Do not continue if there is an error
set -e

# Stop server gracefully when an interrupt singal is received
handle_interrupt() {
  echo -e "\nInterrupt signal received. Stopping server..."

  # Stop Apache server
  apachectl stop

  echo -e "Server stopped."
  echo -e 'Bye!'

  exit 0
}

# Capture and handle SIGTERM (docker stop) and SIGINT (Ctrl+C) signals
trap 'kill ${!}; handle_interrupt ' TERM INT

# Start Apache server
apachectl start

echo -e "Server is running..."
echo -e "Open http://localhost[:PORT]/scl/ in your browser."
echo -e "\nTo stop the server use 'Ctrl+C' or run 'docker stop <container>'"

# Keep container running
while true; do
  tail -f /dev/null &
  wait ${!}
done
