#!/bin/sh

REMOTE_USER="deds"
REMOTE_HOST="home-ubuntu"
REMOTE_DIR="/home/deds/traefik"
LOCAL_DIR="src/traefik"


echo "Copying ${LOCAL_DIR} files to ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}..."
rsync -avz --progress --exclude="acme.json" ${LOCAL_DIR}/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/


echo "Synct completed successfully!"
echo "Restarting docker compose..."
ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_DIR} && docker compose down && docker compose up -d"
echo "Docker compose restarted successfully!"
