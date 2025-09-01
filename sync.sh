#!/bin/sh

REMOTE_USER="deds"
REMOTE_HOST="home-ubuntu"
REMOTE_BASE_DIR="/home/deds"
DOCKER_DIR="src"

# Check if gum is installed
if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed. Please install it first."
    echo "See: https://github.com/charmbracelet/gum#installation"
    exit 1
fi

# Get list of directories in src/
if [ ! -d "$DOCKER_DIR" ]; then
    echo "Error: $DOCKER_DIR directory not found"
    exit 1
fi

DIRECTORIES=$(find "$DOCKER_DIR" -maxdepth 1 -type d -not -path "$DOCKER_DIR" -exec basename {} \;)

if [ -z "$DIRECTORIES" ]; then
    echo "Error: No directories found in $DOCKER_DIR"
    exit 1
fi

# Let user choose directory
echo "Select a directory to sync:"
SELECTED_DIR=$(echo "$DIRECTORIES" | gum choose --header="Available directories:")

if [ -z "$SELECTED_DIR" ]; then
    echo "No directory selected. Exiting."
    exit 1
fi

LOCAL_DIR="$DOCKER_DIR/$SELECTED_DIR"
REMOTE_DIR="$REMOTE_BASE_DIR/$SELECTED_DIR"

echo
gum style --foreground="#00FF00" "Selected directory: $SELECTED_DIR"
echo "Local path: $LOCAL_DIR"
echo "Remote path: $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"
echo

# Confirm sync operation
if ! gum confirm "Proceed with syncing $SELECTED_DIR?"; then
    echo "Sync cancelled."
    exit 0
fi

echo
gum style --foreground="#0099FF" "Copying ${LOCAL_DIR} files to ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}..."
rsync -avz --progress --exclude="acme.json" ${LOCAL_DIR}/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/

if [ $? -eq 0 ]; then
    gum style --foreground="#00FF00" "Sync completed successfully!"
    echo

    # Ask for confirmation before restarting docker compose
    if gum confirm "Restart docker compose on remote server?"; then
        echo
        gum style --foreground="#0099FF" "Restarting docker compose..."
        ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_DIR} && docker compose up -d --build --remove-orphans"

        if [ $? -eq 0 ]; then
            gum style --foreground="#00FF00" "Docker compose restarted successfully!"
        else
            gum style --foreground="#FF0000" "Error: Failed to restart docker compose"
            exit 1
        fi
    else
        echo "Docker compose restart skipped."
    fi
else
    gum style --foreground="#FF0000" "Error: Sync failed"
    exit 1
fi
