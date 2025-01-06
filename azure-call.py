import sys
from azure.communication.callautomation import CallAutomationClient, CallInvite, PhoneNumberIdentifier

def main():
    if len(sys.argv) != 4:
        print("Usage: python call.py <connection_string> <source_number> <target_number>")
        sys.exit(1)

    connection_string = sys.argv[1]  # Connection string for Azure Communication Services resource
    source_number = sys.argv[2]  # Azure Communication Services-provisioned phone number
    target_number = sys.argv[3]  # Target phone number

    # The callback endpoint where you want to receive subsequent events
    callback_uri = "https://jonathan.furmountain.net/Events"

    try:
        # Initialize the CallAutomationClient
        call_automation_client = CallAutomationClient.from_connection_string(connection_string)

        # Create a CallInvite object
        call_invite = CallInvite(
            target=PhoneNumberIdentifier(target_number),
            source_caller_id_number=PhoneNumberIdentifier(source_number)  # Include the caller ID number
        )

        # Start the call
        call_connection_properties = call_automation_client.create_call(call_invite, callback_uri)
        print(f"Call started successfully! CallConnectionId: {call_connection_properties.call_connection_id}")

    except Exception as ex:
        print(f"Failed to start call: {ex}")

if __name__ == "__main__":
    main()
