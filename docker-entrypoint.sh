#!/bin/sh
set -e

# allow re-using the instance - https://stackoverflow.com/a/38732187/2866660
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

exec "$@"
