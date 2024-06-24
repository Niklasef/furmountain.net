#!/bin/bash

# Source the .profile to get environment variables
source /home/niklas/.profile

RESOURCE_GROUP="furmountain-net"
ZONE_NAME="furmountain.net"

# Get the current public IP
CURRENT_IP=$(curl -s https://api.ipify.org)

# Login to Azure
az login --service-principal --username $AZURE_SVC_APP_ID --password $AZURE_SVC_PASSWORD --tenant $AZURE_TENANT_ID

# Delete the existing A record set
az network dns record-set a delete \
    --yes \
    --resource-group $RESOURCE_GROUP \
    --zone-name $ZONE_NAME \
    --name $HOST_NAME \
    --subscription $AZURE_SUBSCRIPTION_ID

# Create a new A record set with the current IP
az network dns record-set a add-record \
    --resource-group $RESOURCE_GROUP \
    --zone-name $ZONE_NAME \
    --record-set-name $HOST_NAME \
    --ipv4-address $CURRENT_IP \
    --subscription $AZURE_SUBSCRIPTION_ID
