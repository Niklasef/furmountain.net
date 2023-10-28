#!/bin/bash

# MQTT Parameters
MQTT_BROKER="localhost"
MQTT_TOPIC="furmountain/johannes/temperature"

# InfluxDB Parameters
INFLUXDB_HOST="localhost"
INFLUXDB_PORT="8086"
INFLUXDB_DATABASE="mydb"
INFLUXDB_MEASUREMENT="mqtt_temperature"


# Function to store data in InfluxDB
function store_in_influxdb {
    local temperature=$1

    # Construct the data line for InfluxDB
    local data="${INFLUXDB_MEASUREMENT},service=temperature,instance=johannes value=${temperature}"

    # Use curl to send the data to InfluxDB
    curl -i -XPOST "http://${INFLUXDB_HOST}:${INFLUXDB_PORT}/write?db=${INFLUXDB_DATABASE}" \
        --data-binary "${data}"
}

# Main loop to listen for MQTT messages and process them
mosquitto_sub -h "${MQTT_BROKER}" -t "${MQTT_TOPIC}" | while read -r message; do
    echo "Received temperature data: ${message}"
    store_in_influxdb "${message}"
done
