#!/usr/bin/env bash

DIR=${INSTALL_DIR:-"/opt/bullwark"}

if [[ -d "$DIR" ]]
then
  /bin/run-parts "$DIR/microservices/entrypoint.d" --verbose
fi

exec "$@"
