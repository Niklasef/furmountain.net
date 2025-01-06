#!/bin/bash

# Parameters
MQTT_BROKER=$1
MQTT_TOPIC="fire-alarm-sound"
LOCAL_MQTT_BROKER="localhost"
LOCAL_MQTT_TOPIC="call"

# Placeholder function for making a call
make_call() {
  local phone_number="+46704127689"  # Placeholder phone number
  local message="Fire alarm detected! Initiating a call to ${phone_number}."

  echo "Making a call to ${phone_number} via Azure..."
  
  # Replace this with the actual Azure service call logic
  # Example: Using Azure CLI to trigger a phone call (Twilio/Azure Communication Service)
  # az communication sms send --to ${phone_number} --from "+YourAzureNumber" --message "${message}"
  
  echo "Call made successfully to ${phone_number} (dummy logic)."
  
  # Return a success message
  echo "$message"
}

# Function to listen for fire alarm signals
listen_to_fire_alarm() {
  echo "Listening for fire alarm signals on $MQTT_BROKER, topic $MQTT_TOPIC..."
  
  mosquitto_sub -h "$MQTT_BROKER" -t "$MQTT_TOPIC" | while read -r message; do
    echo "Received fire alarm signal: $message"

    # Make the call
    call_response=$(make_call)
    
    # Publish a message to the local MQTT broker signaling the call was made
    mosquitto_pub -h "$LOCAL_MQTT_BROKER" -t "$LOCAL_MQTT_TOPIC" -m "$call_response"
    
    echo "Published call status to $LOCAL_MQTT_TOPIC on $LOCAL_MQTT_BROKER."
  done
}

# Check if MQTT_BROKER parameter is provided
if [ -z "$MQTT_BROKER" ]; then
  echo "Usage: $0 <mqtt_broker>"
  exit 1
fi

# Main execution
listen_to_fire_alarm
