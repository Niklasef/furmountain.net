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
INFLUXDB_MEASUREMENT="acked_backups"
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
  echo "Published FILENAME:$filename"

  # Stream the compressed data of the backup file to the MQTT topic
  local line_count=0
  local total_bytes=0
  local chunk
  base64 "$backup_file" | while IFS= read -r line; do
    chunk+="$line"
    total_bytes=$((total_bytes + ${#line}))
    line_count=$((line_count + 1))

    if (( line_count % 100 == 0 )); then
      mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" -t "$MQTT_TOPIC" -m "$chunk"
      chunk=""
      echo "Published $line_count lines, total bytes sent (Base64): $total_bytes"
    fi
  done

  # Publish any remaining data
  if [[ -n "$chunk" ]]; then
    mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" -t "$MQTT_TOPIC" -m "$chunk"
    echo "Published remaining chunk, total bytes sent (Base64): $total_bytes"
  fi

  # Publish EOT (End of Transmission) message
  mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" -t "$MQTT_META_TOPIC" -m "EOT"
  echo "Published EOT, total lines: $line_count, total bytes sent (Base64): $total_bytes"
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
