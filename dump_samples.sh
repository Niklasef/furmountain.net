#!/bin/bash

SPI_DEVICE="/dev/spidev0.0"  # SPI device
SAMPLE_COUNT=10000           # Number of samples to collect
OUTPUT_FILE="raw_samples.txt"

echo "Dumping $SAMPLE_COUNT samples to $OUTPUT_FILE from $SPI_DEVICE..."

# MCP3008 SPI message format:
# - 3 bytes: [Start bit (1), Configuration bits, Zero padding]
# - Configuration for single-ended CH0: 0x01, 0x80, 0x00
START_BYTE=0x01
CONFIG_BYTE=0x80  # Channel 0 (single-ended mode)
DUMMY_BYTE=0x00

# Clear output file
> "$OUTPUT_FILE"

for ((i = 0; i < SAMPLE_COUNT; i++)); do
    # Send SPI command and capture response
    RESPONSE=$(spi-pipe -D "$SPI_DEVICE" -m "${START_BYTE} ${CONFIG_BYTE} ${DUMMY_BYTE}")
    RAW_HEX=$(echo "$RESPONSE" | awk '{print $1$2}')  # Extract raw hex response

    # Convert hex to decimal (10-bit data is in the last 10 bits)
    DECIMAL=$((0x$RAW_HEX >> 6))  # Shift right by 6 bits
    echo "$DECIMAL" >> "$OUTPUT_FILE"
done

echo "Samples saved to $OUTPUT_FILE."
