#!/bin/bash

HOST_NAME=$1

if [ -z "$HOST_NAME" ]; then
    echo "No hostname provided. Exiting."
    exit 1
fi

# Determine if this is the local host instance
IS_LOCAL_HOST=false
if [[ -n "$HOST_NAMES" ]]; then
    # Extract the first string from HOST_NAMES (assuming it is space-separated)
    FIRST_HOST_NAME=$(echo "$HOST_NAMES" | awk '{print $1}')
    if [[ "$HOST_NAME" == "$FIRST_HOST_NAME" ]]; then
        IS_LOCAL_HOST=true
    fi
fi

echo "IS_LOCAL_HOST: $IS_LOCAL_HOST"

publish_local_services() {
    # Ensure required environment variables are set
    if [[ -z "$SERVICES" ]]; then
    echo "Error: Required environment variables (SERVICES) are not set."
    exit 1
    fi

    # Define the MQTT topic
    MQTT_LOCAL_HOST_TOPIC="furmountain/$HOST_NAME"
    MQTT_LOCAL_BROKER="localhost"

    # Publish the SERVICES value to the topic
    echo "Publishing SERVICES to $MQTT_LOCAL_HOST_TOPIC..."
    mosquitto_pub -h "$MQTT_LOCAL_BROKER" -t "$MQTT_LOCAL_HOST_TOPIC" -m "$SERVICES"

    echo "Done!"
}

publish_local_services
