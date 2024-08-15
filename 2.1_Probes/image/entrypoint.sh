#!/bin/sh
TIMESTAMP=$(date +%d-%m-%Y_%T)
DOCUMENT_ROOT=/usr/share/nginx/html

echo "${TIMESTAMP} - Container started" 

# Check if START_DELAY is defined/set or not:
if [ "${START_DELAY}" != "" ]; then
  echo "${TIMESTAMP} - START_DELAY is set to ${START_DELAY} - Simulating a slow-starting container by sleeping for ${START_DELAY} seconds ..."
  sleep ${START_DELAY}
else
  echo "${TIMESTAMP} - START_DELAY was not set, or was set to zero - not sleeping ..."
fi

# Create index.html with a (new) time-stamp-ed message/heading:
TIMESTAMP=$(date +%d-%m-%Y_%T)
MESSAGE="${TIMESTAMP} - Kubernetes probes demo - Web service started"
echo "${MESSAGE}"
echo "<h1>${MESSAGE}</h1>" > ${DOCUMENT_ROOT}/index.html

# Run whatever was passed in CMD:
echo "${TIMESTAMP} - Exec-uting: $@"
exec "$@"
