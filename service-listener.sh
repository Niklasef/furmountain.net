#!/bin/bash

# Source the .profile to get environment variables
source /home/niklas/.profile

# Validate input parameters
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <host> <service>"
    exit 1
fi

# Input parameters
HOST="$1"
SERVICE="$2"

# Determine MQTT broker based on the host
if [[ -n "$HOST_NAMES" ]]; then
    # Extract the first hostname from HOST_NAMES
    FIRST_HOST_NAME=$(echo "$HOST_NAMES" | awk '{print $1}')
    if [[ "$HOST" == "$FIRST_HOST_NAME" ]]; then
        MQTT_BROKER="localhost"
    else
        MQTT_BROKER="${HOST}.furmountain.net:1883"  # Standard MQTT port
    fi
else
    echo "Error: HOST_NAMES environment variable is not set."
    exit 1
fi

# MQTT Parameters
MQTT_TOPIC="${SERVICE}"

# InfluxDB Parameters
INFLUXDB_HOST="localhost"
INFLUXDB_PORT="8086"
INFLUXDB_DATABASE="mydb"
INFLUXDB_MEASUREMENT="${SERVICE}"  # Use service name as measurement

# Function to store data in InfluxDB
function store_in_influxdb {
    local value=$1

    # Construct the data line for InfluxDB
    local data="${INFLUXDB_MEASUREMENT},service=${SERVICE},instance=${HOST} value=${value}"

    # Use curl to send the data to InfluxDB
    curl -i -XPOST "http://${INFLUXDB_HOST}:${INFLUXDB_PORT}/write?db=${INFLUXDB_DATABASE}" \
        --data-binary "${data}"
}

# Main loop to listen for MQTT messages and process them
mosquitto_sub -h "${MQTT_BROKER}" -t "${MQTT_TOPIC}" | while read -r message; do
    echo "Received ${SERVICE} data: ${message}"
    store_in_influxdb "${message}"
done
