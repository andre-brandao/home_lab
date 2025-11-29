#!/bin/sh
# 162f3cc0-d6b4-4ceb-95d0-0ca51071a8a7.cfargotunnel.com
# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Check if gum is available for enhanced UI
USE_GUM=false
if command -v gum &> /dev/null; then
    USE_GUM=true
fi

# Function to print with color
print_status() {
    if [ "$USE_GUM" = true ]; then
        gum style --foreground="#0099FF" "$1"
    else
        echo "${BLUE}$1${NC}"
    fi
}

print_success() {
    if [ "$USE_GUM" = true ]; then
        gum style --foreground="#00FF00" "$1"
    else
        echo "${GREEN}$1${NC}"
    fi
}

print_warning() {
    if [ "$USE_GUM" = true ]; then
        gum style --foreground="#FFAA00" "$1"
    else
        echo "${YELLOW}$1${NC}"
    fi
}

print_error() {
    if [ "$USE_GUM" = true ]; then
        gum style --foreground="#FF0000" "$1"
    else
        echo "${RED}$1${NC}"
    fi
}

# Get current branch name
CURRENT_BRANCH=$(git branch --show-current)

if [ -z "$CURRENT_BRANCH" ]; then
    print_error "Error: Could not determine current branch"
    exit 1
fi

print_status "Current branch: $CURRENT_BRANCH"

# Check if there are any changes to commit
if git diff-index --quiet HEAD --; then
    print_warning "No changes detected. Nothing to commit."

    # Check if we should push anyway
    if [ "$USE_GUM" = true ]; then
        if gum confirm "Push current branch anyway?"; then
            print_status "Pushing current branch..."
            git push origin "$CURRENT_BRANCH"
            if [ $? -eq 0 ]; then
                print_success "Push completed successfully!"
            else
                print_error "Push failed"
                exit 1
            fi
        fi
    else
        echo "Use 'git push' if you want to push without changes."
    fi
    exit 0
fi

# Show status
print_status "Changes to be committed:"
git status --porcelain

echo

# Get custom message if provided as argument
if [ $# -gt 0 ]; then
    COMMIT_MESSAGE="WIP: $*"
else
    # Default WIP message with timestamp
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    COMMIT_MESSAGE="WIP: work in progress - $TIMESTAMP"
fi

print_status "Commit message: $COMMIT_MESSAGE"

# Ask for confirmation if gum is available
if [ "$USE_GUM" = true ]; then
    echo
    if ! gum confirm "Proceed with commit and push?"; then
        print_warning "Operation cancelled."
        exit 0
    fi
fi

echo

# Add all changes
print_status "Adding all changes..."
git add .

# Commit changes
print_status "Committing changes..."
git commit -m "$COMMIT_MESSAGE"

if [ $? -ne 0 ]; then
    print_error "Commit failed"
    exit 1
fi

print_success "Commit successful!"

# Push to origin
print_status "Pushing to origin/$CURRENT_BRANCH..."
git push origin "$CURRENT_BRANCH"

if [ $? -eq 0 ]; then
    print_success "Push completed successfully!"
    print_status "Branch $CURRENT_BRANCH is now up to date on remote"
else
    print_error "Push failed"
    exit 1
fi
