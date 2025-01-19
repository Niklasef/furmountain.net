#!/bin/bash

SPI_DEVICE="/dev/spidev0.0"
SAMPLE_COUNT=10000
OUTPUT_FILE="raw_samples.txt"

echo "Dumping $SAMPLE_COUNT samples to $OUTPUT_FILE from $SPI_DEVICE..."

export SPI_DEVICE

# Clear output file
> "$OUTPUT_FILE"

for ((i = 0; i < SAMPLE_COUNT; i++)); do
    # Send SPI command and capture response
    RESPONSE=$(echo -e "\x01\x80\x00" | spi-pipe)
    RAW_HEX=$(echo "$RESPONSE" | xxd -p -c 2)  # Convert binary to hex

    # Convert hex to decimal (10-bit data is in the last 10 bits)
    DECIMAL=$((0x$RAW_HEX >> 6))  # Shift right by 6 bits
    echo "$DECIMAL" >> "$OUTPUT_FILE"
done

echo "Samples saved to $OUTPUT_FILE."
