#!/bin/bash

# Azure Service Principal Credentials
# APP_ID="your-app-id"
# PASSWORD="your-password/client-secret"
# TENANT_ID="your-tenant-id"

# # Other Azure Details
# SUBSCRIPTION_ID="your-subscription-id"
# RESOURCE_GROUP="your-resource-group"
# ZONE_NAME="your-zone-name"
# RECORD_SET_NAME="your-record-set-name"

# # Get the current public IP
# CURRENT_IP=$(curl -s https://api.ipify.org)

# # Login to Azure
# az login --service-principal --username $APP_ID --password $PASSWORD --tenant $TENANT_ID

# Update DNS A record
az network dns record-set a add-record \
    --resource-group $RESOURCE_GROUP \
    --zone-name $ZONE_NAME \
    --record-set-name $RECORD_SET_NAME \
    --ipv4-address $CURRENT_IP \
    --subscription $SUBSCRIPTION_ID
