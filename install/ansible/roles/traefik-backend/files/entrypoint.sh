#!/usr/bin/env bash

DIR=${INSTALL_DIR:-"/opt/bullwark"}

if [[ -d "$DIR" ]]
then
  /bin/run-parts "$DIR/traefik-backend/entrypoint.d" --verbose
fi

exec "$@"
