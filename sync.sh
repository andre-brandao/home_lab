#!/bin/sh

REMOTE_USER="deds"
REMOTE_HOST="home-ubuntu"
REMOTE_DIR="/home/deds/monitoring"
LOCAL_DIR="src/monitoring"


echo "Copying ${LOCAL_DIR} files to ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}..."
rsync -avz --progress ${LOCAL_DIR}/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/


echo "Synct completed successfully!"
