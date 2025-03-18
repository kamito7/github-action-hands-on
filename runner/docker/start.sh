#!/bin/bash

set -euo pipefail

# Define short and long options
OPTIONS="o:n:l:t:"
LONGOPTIONS="owner:,name:,label:,token:"

# Use `getopt` to parse options
PARSED=$(getopt -o "$OPTIONS" --longoptions "$LONGOPTIONS" -- "$@")

# Reassign the parsed options
eval set -- "$PARSED"

# Initialize variables
OWNER=""
NAME=""
LABEL=""
TOKEN=""

# Process parsed options
while true; do
    case "$1" in
        -o|--owner)
            OWNER="$2"  # Store the owner (required)
            shift 2
            ;;
        -n|--name)
            NAME="$2"  # Store the name (optional)
            shift 2
            ;;
        -l|--label)
            LABEL="$2"  # Store the label (optional)
            shift 2
            ;;
        -t|--token)
            TOKEN="$2"  # Store the access token (required)
            shift 2
            ;;
        --)
            shift  # End of options
            break
            ;;
        *)
            echo "Error: Unknown option specified." >&2
            exit 1
            ;;
    esac
done

# Apply a workaround patch for the push boot button issue on T3P devices
if [ "$DEVICE_TYPE" = "T3P" ]; then
    echo "Checking esptool version..."

    if esptool.py version 2>/dev/null | grep -qE "patch"; then
        echo "Patch is already applied."
    else
        cd /home/runner
        echo "Applying patch..."
        if patch -p1 -d esptool < push_bootbutton_workaround_v4.7.0.patch; then
            echo "Patch applied successfully."
        else
            echo "Warning: Patch may have failed or is already applied."
        fi

        # Reinstall esptool with the applied patch
        pip install --user -e esptool
    fi
fi
# Navigate to actions-runner directory
cd /opt/docker-actions-runner

# Configure the runner with the registration token
if [[ -f .credentials && -f .runner ]]; then
    echo "Runner already configured. Skipping config.sh."
else
    if [[ -n "$TOKEN" && -n "$OWNER" ]]; then
        CONFIG_CMD=(./config.sh --url "https://github.com/${OWNER}" --token "${TOKEN}" --unattended)
        [[ -n "$LABEL" ]] && CONFIG_CMD+=(--labels "${LABEL}")
        [[ -n "$NAME" ]] && CONFIG_CMD+=(--name "${NAME}")

        # Execute command
        echo "Executing: ${CONFIG_CMD[*]}"
        "${CONFIG_CMD[@]}"
    else
        echo "ERROR: TOKEN and OWNER must be provided for first-time setup."
        exit 1
    fi
fi

# Define a cleanup function to remove the runner on exit
#cleanup() {
#    echo "Removing runner..."
#    ./config.sh remove --unattended --token ${ACCESS_TOKEN}
#}

# Set up traps to catch termination signals and run cleanup
#trap 'cleanup; exit 130' INT
#trap 'cleanup; exit 143' TERM

# Run the GitHub Actions runner and wait for its completion
./run.sh & wait $!
