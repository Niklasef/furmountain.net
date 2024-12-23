#!/bin/bash

HOST_NAME=$1

if [ -z "$HOST_NAME" ]; then
    echo "No hostname provided. Exiting."
    exit 1
fi

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