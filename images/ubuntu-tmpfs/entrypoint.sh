#!/bin/bash
set -e

# Create the directory in /run with myuser permissions
gosu myuser mkdir -p /run/myapp

# Execute the command with the specified user
exec gosu myuser "$@"