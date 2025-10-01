#!/bin/sh

REMOTE_USER="deds"
REMOTE_HOST="home-ubuntu"
REMOTE_BASE_DIR="/home/deds"
DOCKER_DIR="src"

# Action definitions
ACTION_EXIT="Exit"

# Sync function
ACTION_SYNC="Sync files"
sync_files() {
    local local_dir="$1"
    local remote_dir="$2"

    gum style --foreground="#0099FF" "Copying ${local_dir} files to ${REMOTE_USER}@${REMOTE_HOST}:${remote_dir}..."
    rsync -avz --progress --exclude="acme.json" ${local_dir}/ ${REMOTE_USER}@${REMOTE_HOST}:${remote_dir}/
    return $?
}

# Docker Compose Functions
ACTION_COMPOSE_UP="Up (build & start)"
compose_up() {
    local remote_dir="$1"
    gum style --foreground="#0099FF" "Starting docker compose (up -d --build --remove-orphans)..."
    ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${remote_dir} && docker compose up -d --build --remove-orphans"
    return $?
}

ACTION_COMPOSE_DOWN="Down (stop)"
compose_down() {
    local remote_dir="$1"
    gum style --foreground="#0099FF" "Stopping docker compose (down)..."
    ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${remote_dir} && docker compose down"
    return $?
}

ACTION_COMPOSE_RESTART="Restart (restart containers)"
compose_restart() {
    local remote_dir="$1"
    gum style --foreground="#0099FF" "Restarting docker compose..."
    ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${remote_dir} && docker compose restart"
    return $?
}

ACTION_COMPOSE_REBUILD="Rebuild (down, build, up)"
compose_rebuild() {
    local remote_dir="$1"
    gum style --foreground="#0099FF" "Rebuilding and starting docker compose..."
    ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${remote_dir} && docker compose down && docker compose up -d --build --remove-orphans"
    return $?
}

ACTION_COMPOSE_LOGS="Logs (show recent logs)"
compose_logs() {
    local remote_dir="$1"
    gum style --foreground="#0099FF" "Showing docker compose logs (last 50 lines)..."
    ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${remote_dir} && docker compose logs --tail=50"
    return $?
}

ACTION_COMPOSE_STATUS="Status (show container status)"
compose_status() {
    local remote_dir="$1"
    gum style --foreground="#0099FF" "Showing docker compose status..."
    ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${remote_dir} && docker compose ps"
    return $?
}

# New Update action: Pull new images and restart containers
ACTION_COMPOSE_UPDATE="Update (pull new images & restart)"
compose_update() {
    local remote_dir="$1"
    gum style --foreground="#0099FF" "Updating docker compose: pulling images and restarting containers..."
    ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${remote_dir} && docker compose pull && docker compose up -d --build --remove-orphans"
    return $?
}

# Check if gum is installed
if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed. Please install it first."
    echo "See: https://github.com/charmbracelet/gum#installation"
    exit 1
fi


if [ ! -d "$DOCKER_DIR" ]; then
    echo "Error: $DOCKER_DIR directory not found"
    exit 1
fi

DIRECTORIES=$(find "$DOCKER_DIR" -maxdepth 1 -type d -not -path "$DOCKER_DIR" -exec basename {} \;)

if [ -z "$DIRECTORIES" ]; then
    echo "Error: No directories found in $DOCKER_DIR"
    exit 1
fi


echo "Select a directory to work with:"
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

# Main action loop
while true; do
    echo "What would you like to do?"
    ACTION=$(gum choose --header="Choose an action:" \
        "$ACTION_SYNC" \
        "$ACTION_COMPOSE_UP" \
        "$ACTION_COMPOSE_DOWN" \
        "$ACTION_COMPOSE_RESTART" \
        "$ACTION_COMPOSE_REBUILD" \
        "$ACTION_COMPOSE_LOGS" \
        "$ACTION_COMPOSE_STATUS" \
        "$ACTION_COMPOSE_UPDATE" \
        "$ACTION_EXIT")

    case "$ACTION" in
        "$ACTION_SYNC")
            echo
            if gum confirm "Proceed with syncing $SELECTED_DIR?"; then
                if sync_files "$LOCAL_DIR" "$REMOTE_DIR"; then
                    gum style --foreground="#00FF00" "Sync completed successfully!"
                else
                    gum style --foreground="#FF0000" "Error: Sync failed"
                fi
            else
                echo "Sync cancelled."
            fi
            echo
            ;;
        "$ACTION_COMPOSE_UP")
            echo
            if compose_up "$REMOTE_DIR"; then
                gum style --foreground="#00FF00" "Docker compose started successfully!"
            else
                gum style --foreground="#FF0000" "Error: Failed to start docker compose"
            fi
            echo
            ;;
        "$ACTION_COMPOSE_DOWN")
            echo
            if compose_down "$REMOTE_DIR"; then
                gum style --foreground="#00FF00" "Docker compose stopped successfully!"
            else
                gum style --foreground="#FF0000" "Error: Failed to stop docker compose"
            fi
            echo
            ;;
        "$ACTION_COMPOSE_RESTART")
            echo
            if compose_restart "$REMOTE_DIR"; then
                gum style --foreground="#00FF00" "Docker compose restarted successfully!"
            else
                gum style --foreground="#FF0000" "Error: Failed to restart docker compose"
            fi
            echo
            ;;
        "$ACTION_COMPOSE_REBUILD")
            echo
            if compose_rebuild "$REMOTE_DIR"; then
                gum style --foreground="#00FF00" "Docker compose rebuilt and started successfully!"
            else
                gum style --foreground="#FF0000" "Error: Failed to rebuild docker compose"
            fi
            echo
            ;;
        "$ACTION_COMPOSE_LOGS")
            echo
            compose_logs "$REMOTE_DIR"
            echo
            ;;
        "$ACTION_COMPOSE_STATUS")
            echo
            compose_status "$REMOTE_DIR"
            echo
            ;;
        "$ACTION_COMPOSE_UPDATE")
            echo
            if compose_update "$REMOTE_DIR"; then
                gum style --foreground="#00FF00" "Docker compose updated successfully!"
            else
                gum style --foreground="#FF0000" "Error: Failed to update docker compose"
            fi
            echo
            ;;
        "$ACTION_EXIT")
            gum style --foreground="#00FF00" "Goodbye!"
            exit 0
            ;;
        *)
            echo "Canceled by user. Exiting."
            exit 0
            ;;
    esac
done
