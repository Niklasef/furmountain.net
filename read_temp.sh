#!/bin/bash

# Define the device directory with the directory you've identified
DEVICE_DIR="/sys/bus/w1/devices/28-3ce1e3816f48"

# Path to the file containing the temperature data
TEMP_FILE="$DEVICE_DIR/w1_slave"

# A function that reads the temperature
read_temp() {
  # Read the temperature from the device file
  TEMP_DATA=$(cat $TEMP_FILE)
  echo "Raw data: $TEMP_DATA"  # Print raw data for debugging

  # Extract the temperature from the raw data
  TEMP_RAW=$(echo "$TEMP_DATA" | awk -F 't=' '/t=/ {print $2}')
  echo "Extracted temperature data: $TEMP_RAW"  # Print extracted data for debugging

  # Check if TEMP_RAW is empty or not set
  if [ -z "$TEMP_RAW" ]; then
    echo "No temperature data found."
    return  # Exit the function early
  fi

  # Convert the temperature to degrees Celsius. The temperature data from the file is in millidegrees Celsius.
  TEMP_C=$(echo "scale=3; $TEMP_RAW / 1000" | bc)
  
  # Print the temperature
  echo "Temperature: $TEMP_C °C"
}

# Main execution
# Check if the temperature file exists (meaning the device is correctly connected)
if [ -f "$TEMP_FILE" ]; then
  read_temp
else
  echo "Error: Device not found. Please check the device connection."
fi

