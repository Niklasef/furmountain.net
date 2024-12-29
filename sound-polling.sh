#!/bin/bash

MQTT_BROKER="localhost"
MQTT_TOPIC="sound-polling"

# Generate a random dummy sound intensity value
generate_dummy_sound() {
  # Simulate sound intensity as a random value between 30 and 100 dB
  SOUND_INTENSITY=$((30 + RANDOM % 71))  # Random value in the range [30, 100]
  echo "Generated dummy sound intensity: $SOUND_INTENSITY dB"

  # Publish the sound intensity to the MQTT topic
  mosquitto_pub -h "$MQTT_BROKER" -t "$MQTT_TOPIC" -m "$SOUND_INTENSITY"
}

# Main execution
echo "Polling sound intensity..."
generate_dummy_sound
echo "Sound intensity published to $MQTT_TOPIC"
