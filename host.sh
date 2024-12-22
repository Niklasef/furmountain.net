#!/bin/bash

# A simple Hello World script for verification

FIRST_HOST_NAME=$1

if [ -z "$FIRST_HOST_NAME" ]; then
    echo "No hostname provided. Exiting."
    exit 1
fi

# Log the hostname and a simple message
echo "Hello, World! This is the hostname: $FIRST_HOST_NAME"
