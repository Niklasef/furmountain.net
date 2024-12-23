#!/bin/bash

FIRST_HOST_NAME=$1

if [ -z "$FIRST_HOST_NAME" ]; then
    echo "No hostname provided. Exiting."
    exit 1
fi

# Ensure required environment variables are set
if [[ -z "$SERVICES" ]]; then
  echo "Error: Required environment variables (SERVICES) are not set."
  exit 1
fi

# Define the MQTT topic
MQTT_TOPIC="furmountain/$FIRST_HOST_NAME"
MQTT_BROKER="localhost"

# Publish the SERVICES value to the topic
echo "Publishing SERVICES to $MQTT_TOPIC..."
mosquitto_pub -h "$MQTT_BROKER" -t "$MQTT_TOPIC" -m "$SERVICES"

echo "Done!"
