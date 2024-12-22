#!/bin/bash

# Source the .profile to get environment variables
source /home/niklas/.profile

RESOURCE_GROUP="furmountain-net"
ZONE_NAME="furmountain.net"

# Function to update DNS records
update_dns() {
    # Get the current public IP
    CURRENT_IP=$(curl -s https://api.ipify.org)

    # Login to Azure
    az login --service-principal --username "$AZURE_SVC_APP_ID" --password "$AZURE_SVC_PASSWORD" --tenant "$AZURE_TENANT_ID"

    # Convert HOST_NAMES into an array
    IFS=' ' read -r -a HOST_NAMES_ARRAY <<< "$HOST_NAMES"

    # Check if there are any hostnames
    if [ ${#HOST_NAMES_ARRAY[@]} -eq 0 ]; then
        echo "No hostnames provided in HOST_NAMES. Exiting."
        return
    fi

    # Register the first hostname as an A record
    FIRST_HOST_NAME=${HOST_NAMES_ARRAY[0]}
    echo "Registering A record for: $FIRST_HOST_NAME"

    az network dns record-set a delete \
        --yes \
        --resource-group "$RESOURCE_GROUP" \
        --zone-name "$ZONE_NAME" \
        --name "$FIRST_HOST_NAME" \
        --subscription "$AZURE_SUBSCRIPTION_ID"

    az network dns record-set a add-record \
        --resource-group "$RESOURCE_GROUP" \
        --zone-name "$ZONE_NAME" \
        --record-set-name "$FIRST_HOST_NAME" \
        --ipv4-address "$CURRENT_IP" \
        --subscription "$AZURE_SUBSCRIPTION_ID"

    # Loop through the remaining hostnames and register as CNAME records
    for ((i = 1; i < ${#HOST_NAMES_ARRAY[@]}; i++)); do
        HOST_NAME=${HOST_NAMES_ARRAY[i]}
        echo "Registering CNAME record for: $HOST_NAME pointing to $FIRST_HOST_NAME.$ZONE_NAME"

        az network dns record-set cname delete \
            --yes \
            --resource-group "$RESOURCE_GROUP" \
            --zone-name "$ZONE_NAME" \
            --name "$HOST_NAME" \
            --subscription "$AZURE_SUBSCRIPTION_ID"

        az network dns record-set cname set-record \
            --resource-group "$RESOURCE_GROUP" \
            --zone-name "$ZONE_NAME" \
            --record-set-name "$HOST_NAME" \
            --cname "$FIRST_HOST_NAME.$ZONE_NAME" \
            --subscription "$AZURE_SUBSCRIPTION_ID"
    done
}

# Function to set up the host environment
setup_host() {
    local FIRST_HOST_NAME=$1

    echo "Setting up the host environment for $FIRST_HOST_NAME..."

    echo "Registering cron job for host.sh..."
    CRON_JOB="*/15 * * * * /home/niklas/furmountain.net/host.sh $FIRST_HOST_NAME > /home/niklas/host.log 2>&1"

    # Add the cron job if it doesn't already exist
    (crontab -l 2>/dev/null | grep -v -F "$CRON_JOB"; echo "$CRON_JOB") | crontab -

    echo "Cron job registered successfully for $FIRST_HOST_NAME."
    echo "Host environment setup complete."
}

# Function to list all FQDNs
list_fqdns() {
    echo "Fetching all FQDNs from Azure DNS..."
    A_FQDNS=$(az network dns record-set list \
        --resource-group "$RESOURCE_GROUP" \
        --zone-name "$ZONE_NAME" \
        --subscription "$AZURE_SUBSCRIPTION_ID" \
        --query "[?type=='Microsoft.Network/dnszones/A'].fqdn" \
        --output tsv)

    # Convert the result into an array
    IFS=$'\n' read -r -d '' -a A_FQDNS_ARRAY <<< "$A_FQDNS"

    # Filter out the first hostname from HOST_NAMES_ARRAY
    REMOTE_FQDNS=()
    for FQDN in "${A_FQDNS_ARRAY[@]}"; do
        if [[ "$FQDN" != "${HOST_NAMES_ARRAY[0]}.$ZONE_NAME." ]]; then
            REMOTE_FQDNS+=("$FQDN")
        fi
    done

    # Print each remote FQDN
    echo "List of remote FQDNs for A records (excluding the first host):"
    for FQDN in "${REMOTE_FQDNS[@]}"; do
        echo "$FQDN"
    done
}

# Extract the first hostname from HOST_NAMES and pass it to setup_host
IFS=' ' read -r -a HOST_NAMES_ARRAY <<< "$HOST_NAMES"
setup_host "${HOST_NAMES_ARRAY[0]}"
update_dns
list_fqdns
