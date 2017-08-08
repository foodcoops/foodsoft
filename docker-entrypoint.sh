#!/bin/sh
set -e

CRONTAB="$(crontab -l)"
CRONTAB_ENV=""

if test -n "$BUNDLE_APP_CONFIG"; then
  CRONTAB_ENV="${CRONTAB_ENV}BUNDLE_APP_CONFIG=$BUNDLE_APP_CONFIG\n"
fi

if test -n "$DATABASE_URL"; then
  CRONTAB_ENV="${CRONTAB_ENV}DATABASE_URL=$DATABASE_URL\n"
fi

echo "$CRONTAB_ENV$CRONTAB" | crontab -

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

exec "$@"
