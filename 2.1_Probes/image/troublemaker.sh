#!/bin/sh
TIMESTAMP=$(date +%d-%m-%Y_%T)
READINESSCHECK_FILE=/shared/readinesscheck.txt
LIVENESSCHECK_FILE=/shared/livenesscheck.txt


function create_readinesscheck_file()
{
  while true; do 
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    DURATION=${RANDOM:1:2}
    echo "${TIMESTAMP} - Sleeping for ${DURATION} seconds before creating the readiness-check file ..."
    sleep ${DURATION}
    echo readinesscheck > ${READINESSCHECK_FILE}
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    echo "${TIMESTAMP} - Created readiness-check file: '${READINESSCHECK_FILE}' after sleeping for ${DURATION} seconds ..."
    
  done
}

function delete_readinesscheck_file()
{
  while true; do
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    DURATION=${RANDOM:1:2}
    echo "${TIMESTAMP} - Sleeping for ${DURATION} seconds before deleting the readiness-check file ..."
    sleep ${DURATION}
    rm ${READINESSCHECK_FILE}
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    echo "${TIMESTAMP} - Deleted readiness-check file: '${READINESSCHECK_FILE}' after sleeping for ${DURATION} seconds ..."
  done
}

function create_livenesscheck_file()
{
  while true; do 
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    DURATION=${RANDOM:1:2}
    echo "${TIMESTAMP} - Sleeping for ${DURATION} seconds before creating the liveness-check file ..."
    sleep ${DURATION}
    echo livenesscheck > ${LIVENESSCHECK_FILE}
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    echo "${TIMESTAMP} - Created liveness-check file: '${LIVENESSCHECK_FILE}' after sleeping for ${DURATION} seconds ..."
  done
}

function delete_livenesscheck_file()
{
  while true; do
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    DURATION=${RANDOM:1:2}
    echo "${TIMESTAMP} - Sleeping for ${DURATION} seconds before deleting the livenesscheck file ..."
    sleep ${DURATION}
    rm ${LIVENESSCHECK_FILE}
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    echo "${TIMESTAMP} - Deleted liveness-check file: '${LIVENESSCHECK_FILE}' after sleeping for ${DURATION} seconds ..."
  done
}

# Change the port of nginx to 8888
sed -i "s/80;/8888;/g" /etc/nginx/conf.d/default.conf

if [ "${ROLE}" == "TROUBLEMAKER" ]; then
  MESSAGE=" ${TIMESTAMP} - Started container in TROUBLEMAKER mode - on port 8888"
  echo ${MESSAGE}
  echo "<h1>${MESSAGE}</h1>" > /usr/share/nginx/html/index.html
  
  # Fork the following processes, 
  #  so they keep doing their thing in the background, with random delay.
  
  echo "${TIMESTAMP} - Forking create_readiness-check_file in background..."
  create_readinesscheck_file &

  echo "${TIMESTAMP} - Forking delete_readiness-check_file in background..."
  delete_readinesscheck_file &

  echo "${TIMESTAMP} - Forking create_liveness-check_file in background..."
  create_livenesscheck_file &

  echo "${TIMESTAMP} - Forking delete_liveness-check_file in background..."
  delete_livenesscheck_file &


else

  MESSAGE="${TIMESTAMP} - Started container in NORMAL mode - on port 8888"
  echo ${MESSAGE}
  echo "<h1>${MESSAGE}</h1>" > /usr/share/nginx/html/index.html

fi


# Run whatever was passed in CMD.
echo "Exec-uting: $@"
exec "$@"
