#!/usr/bin/env bash

set -euo pipefail

# Configuration
STACKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/stacks" && pwd)"
REMOTE_HOST="arrflix"
REMOTE_USER="docker"
REMOTE_STACKS_DIR="/home/docker/stacks"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if gum is installed
if ! command -v gum &> /dev/null; then
    echo -e "${RED}Error: gum is not installed${NC}"
    echo "Install it with: https://github.com/charmbracelet/gum#installation"
    exit 1
fi

# Display header
gum style \
    --border double \
    --border-foreground 212 \
    --padding "1 2" \
    --margin "1 0" \
    "Arrflix Stack Deployment" \
    "Sync and deploy Docker stacks"

# Check SSH connectivity
gum spin --spinner dot --title "Checking SSH connectivity to ${REMOTE_HOST}..." -- \
    ssh -o ConnectTimeout=5 "${REMOTE_USER}@${REMOTE_HOST}" "echo 'Connected'" > /dev/null 2>&1 || {
    gum style --foreground 196 "Failed to connect to ${REMOTE_HOST}"
    exit 1
}

gum style --foreground 2 "✓ SSH connection successful"
echo

# Get list of stacks
STACKS=($(find "${STACKS_DIR}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort))

if [ ${#STACKS[@]} -eq 0 ]; then
    gum style --foreground 196 "No stacks found in ${STACKS_DIR}"
    exit 1
fi

gum style --foreground 212 "Found ${#STACKS[@]} stack(s): ${STACKS[*]}"
gum style --foreground 8 "Local path: ${STACKS_DIR}"
gum style --foreground 8 "Remote path: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_STACKS_DIR}"
echo

# Confirm deployment
gum confirm "Do you want to sync and deploy all stacks?" || {
    gum style --foreground 3 "Deployment cancelled"
    exit 0
}

echo

# Create remote stacks directory if it doesn't exist
echo "Creating remote directory..."
ssh "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p ${REMOTE_STACKS_DIR}" || {
    gum style --foreground 196 "Failed to create remote directory"
    exit 1
}
gum style --foreground 2 "✓ Remote directory ready"
echo

# Sync each stack
for stack in "${STACKS[@]}"; do
    gum style --border normal --border-foreground 212 --padding "0 1" "Syncing stack: ${stack}"
    echo

    # Show what we're syncing
    gum style --foreground 8 "Source: ${STACKS_DIR}/${stack}/"
    gum style --foreground 8 "Destination: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_STACKS_DIR}/${stack}/"
    echo

    # Use rsync to sync the stack directory with verbose output
    if rsync -avzh --progress \
        --exclude='config/acme.json' \
        --exclude='logs/' \
        --exclude='*.log' \
        "${STACKS_DIR}/${stack}/" \
        "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_STACKS_DIR}/${stack}/"; then
        gum style --foreground 2 "✓ ${stack} synced successfully"
    else
        gum style --foreground 196 "✗ Failed to sync ${stack}"
        exit 1
    fi
    echo
done

# Deploy each stack
gum style --border double --border-foreground 212 --padding "0 1" --margin "1 0" \
    "Deploying stacks"
echo

for stack in "${STACKS[@]}"; do
    gum style --foreground 212 --bold "Deploying: ${stack}"

    # Check if compose.yaml exists
    COMPOSE_FILE="compose.yaml"
    if ! ssh "${REMOTE_USER}@${REMOTE_HOST}" "test -f ${REMOTE_STACKS_DIR}/${stack}/${COMPOSE_FILE}"; then
        # Try docker-compose.yml
        COMPOSE_FILE="docker-compose.yml"
        if ! ssh "${REMOTE_USER}@${REMOTE_HOST}" "test -f ${REMOTE_STACKS_DIR}/${stack}/${COMPOSE_FILE}"; then
            gum style --foreground 3 "⚠ No compose file found for ${stack}, skipping"
            echo
            continue
        fi
    fi

    # Run docker compose up -d with output
    echo "Running: docker compose up -d"
    if ssh "${REMOTE_USER}@${REMOTE_HOST}" \
        "cd ${REMOTE_STACKS_DIR}/${stack} && docker compose up -d"; then
        gum style --foreground 2 "✓ ${stack} deployed successfully"
    else
        gum style --foreground 196 "✗ Failed to deploy ${stack}"
    fi

    echo
done

# Summary
gum style \
    --border rounded \
    --border-foreground 2 \
    --padding "1 2" \
    --margin "1 0" \
    "Deployment Complete!" \
    "" \
    "All stacks have been synced and deployed to ${REMOTE_HOST}"

# Optional: Show running containers
if gum confirm "Would you like to see running containers on ${REMOTE_HOST}?"; then
    echo
    gum style --foreground 212 "Running containers:"
    ssh "${REMOTE_USER}@${REMOTE_HOST}" "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
fi
