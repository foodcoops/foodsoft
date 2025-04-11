#!/bin/sh
set -e

# allow re-using the instance - https://stackoverflow.com/a/38732187/2866660
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

if [ ! -z "${FOODSOFT_DB_PREFIX}" ] || [ ! -z "${FOODSOFT_DB_PREFIX_FILE}" ]; then
  FOODSOFT_FOODCOOPS=`BUNDLE_CONFIG=/dev/null bundle exec ruby script/list_databases`
fi

if [ -e app_config.defaults.yml ] ; then
  cat app_config.defaults.yml > config/app_config.yml

  for FOODCOOP in $FOODSOFT_FOODCOOPS; do
    cat << EOF >> config/app_config.yml
$FOODCOOP:
  <<: *defaults
  database:
    database: foodsoft_$FOODCOOP
EOF
  done
fi

exec "$@"
