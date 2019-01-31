#!/usr/bin/env bash

INSTALL_DIR=${INSTALL_DIR:-"/opt/bullwark"}
REGISTRAR_HOST=${REGISTRAR_HOST:-localhost}
REGISTRAR_PORT=${REGISTRAR_PORT:-8000}

# Register microservice server
#
curl -H "Content-Type: application/json" \
     --data @${INSTALL_DIR}/microservices/conf/bullwark-microservice-server.json \
     http://${REGISTRAR_HOST}:${REGISTRAR_PORT}/register
