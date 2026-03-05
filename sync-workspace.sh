#!/bin/bash
# sync-workspace.sh - Auto-sync script for agent shared workspace

REPO_DIR="${AGENT_WORKSPACE:-$HOME/agent-shared-workspace}"
AGENT_NAME="${AGENT_NAME:-unknown}"
SYNC_INTERVAL="${SYNC_INTERVAL:-300}"  # 5 minutes default

cd "$REPO_DIR" || exit 1

# Function to pull latest
pull_latest() {
    git stash push -m "auto-stash-$(date +%s)" 2>/dev/null
    git pull origin main --rebase
    git stash pop 2>/dev/null
}

# Function to commit and push changes
push_changes() {
    if [[ -n $(git status --porcelain) ]]; then
        git add -A
        git commit -m "[$AGENT_NAME] Auto-sync: $(date -u '+%Y-%m-%d %H:%M UTC')" || true
        git push origin main
    fi
}

# Function for background sync loop
background_sync() {
    while true; do
        sleep "$SYNC_INTERVAL"
        pull_latest
        push_changes
    done
}

# Handle command
case "$1" in
    start)
        echo "[$AGENT_NAME] Pulling latest..."
        pull_latest
        echo "[$AGENT_NAME] Starting background sync (every ${SYNC_INTERVAL}s)..."
        background_sync &
        echo $! > /tmp/agent-sync-$AGENT_NAME.pid
        ;;
    stop)
        if [[ -f /tmp/agent-sync-$AGENT_NAME.pid ]]; then
            kill $(cat /tmp/agent-sync-$AGENT_NAME.pid) 2>/dev/null
            rm /tmp/agent-sync-$AGENT_NAME.pid
        fi
        echo "[$AGENT_NAME] Pushing final changes..."
        push_changes
        ;;
    sync-now)
        pull_latest
        push_changes
        ;;
    *)
        echo "Usage: $0 {start|stop|sync-now}"
        echo ""
        echo "Environment variables:"
        echo "  AGENT_WORKSPACE - Path to repo (default: ~/agent-shared-workspace)"
        echo "  AGENT_NAME      - Agent identifier for commits"
        echo "  SYNC_INTERVAL   - Seconds between syncs (default: 300)"
        exit 1
        ;;
esac
