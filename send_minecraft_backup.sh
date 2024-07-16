#!/bin/bash

# Define the backup directory
BACKUP_DIR="/home/niklas/minecraft_backups"

# MQTT details
MQTT_BROKER="localhost"
MQTT_PORT="1883"
MQTT_TOPIC="furmountain/jonathan/minecraft_backup/data"
MQTT_META_TOPIC="furmountain/jonathan/minecraft_backup/meta"

# InfluxDB Parameters
INFLUXDB_HOST="localhost"
INFLUXDB_PORT="8086"
INFLUXDB_DATABASE="mydb"
INFLUXDB_MEASUREMENT="acked_minecraft_backups"
INFLUXDB_TAG="jonathan"

# Function to fetch acknowledged filenames from InfluxDB
fetch_acked_filenames() {
  curl -sG "http://${INFLUXDB_HOST}:${INFLUXDB_PORT}/query" \
    --data-urlencode "db=${INFLUXDB_DATABASE}" \
    --data-urlencode "q=SELECT filename FROM ${INFLUXDB_MEASUREMENT} WHERE service='backup' AND instance='${INFLUXDB_TAG}'" | jq -r '.results[0].series[0].values[][1]'
}

# Function to publish backup data to the MQTT topic
publish_backup() {
  local backup_file="$1"
  local filename=$(basename "$backup_file")
  echo "Processing backup: $backup_file"

  # Publish the filename
  mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" -t "$MQTT_META_TOPIC" -m "FILENAME:$filename"

  # Stream the data of the backup file to the MQTT topic
  gzip -cd "$backup_file" | while IFS= read -r line; do
    mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" -t "$MQTT_TOPIC" -m "$line"
  done

  # Publish EOT (End of Transmission) message
  mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" -t "$MQTT_META_TOPIC" -m "EOT"
}

# Main execution
# Fetch the list of acknowledged filenames from InfluxDB
ACKED_FILES=$(fetch_acked_filenames)
echo "Acknowledged files: $ACKED_FILES"

# Find the oldest backup file not in the acknowledged list
for backup_file in $(ls -t "$BACKUP_DIR"/*.tar.gz); do
  filename=$(basename "$backup_file")
  if ! echo "$ACKED_FILES" | grep -q "$filename"; then
    # If the file is not acknowledged, publish it
    publish_backup "$backup_file"
    break
  fi
done