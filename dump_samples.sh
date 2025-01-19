#!/bin/bash

SPI_DEVICE="/dev/spidev0.0"  # Specify the SPI device
SAMPLE_COUNT=10000           # Number of samples to collect
OUTPUT_FILE="raw_samples.txt"

echo "Dumping $SAMPLE_COUNT samples to $OUTPUT_FILE from $SPI_DEVICE..."

# Clear output file
> "$OUTPUT_FILE"

for ((i = 0; i < SAMPLE_COUNT; i++)); do
    # Send SPI command and capture response
    RESPONSE=$(echo -e "\x01\x80\x00" | spi-pipe --device="$SPI_DEVICE" --speed=500000 --blocksize=3)
    RAW_HEX=$(echo "$RESPONSE" | hexdump -v -e '/1 "%02X"' | cut -c 1-6)

    # Convert hex to decimal (10-bit data is in the last 10 bits)
    DECIMAL=$((0x${RAW_HEX:1:4} >> 6))  # Extract 10 bits and convert
    echo "$DECIMAL" >> "$OUTPUT_FILE"
done

echo "Samples saved to $OUTPUT_FILE."
