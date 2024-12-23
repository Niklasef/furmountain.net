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

setup_local_services() {
    if [[ -z "$SERVICES" ]]; then
        echo "Error: Required environment variable (SERVICES) is not set."
        exit 1
    fi

    echo "Setting up the services for $FIRST_HOST_NAME..."

    # Loop through each service in $SERVICES
    for SERVICE in $SERVICES; do
        echo "Registering cron job for $SERVICE..."

        # Define the cron job
        CRON_JOB="*/15 * * * * /home/niklas/furmountain.net/${SERVICE}.sh > /home/niklas/${SERVICE}.log 2>&1"

        # Add the cron job if it doesn't already exist
        (crontab -l 2>/dev/null | grep -v -F "$CRON_JOB"; echo "$CRON_JOB") | crontab -

        echo "Cron job for $SERVICE registered."
    done
    echo "Local services setup completed."
}

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

if [[ "$IS_LOCAL_HOST" == true ]]; then
    setup_local_services
    publish_local_services
else
    echo "This is not the local host instance. Skipping service publication."
fi
