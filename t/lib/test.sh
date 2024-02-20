#/bin/bash

echo "test output coming..."
echo "$0 $*"
echo "ARGS:"
printf '%s\n' "$@"

echo "ENV:"
env
