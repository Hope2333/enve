#!/usr/bin/env bash
#
# watch-build-status.sh - Monitor GitHub Actions build status
#
# Usage:
#   ./scripts/ci/watch-build-status.sh [REPO] [RUN_ID] [INTERVAL]
#
# Defaults:
#   REPO    - Hope2333/enve
#   RUN_ID  - Latest in-progress run for chore/linux-baseline-actions
#   INTERVAL - 45 seconds
#

set -euo pipefail

REPO="${1:-Hope2333/enve}"
RUN_ID="${2:-}"
INTERVAL="${3:-45}"
WORKFLOW="linux-baseline.yml"
BRANCH="chore/linux-baseline-actions"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%H:%M:%S') - $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%H:%M:%S') - $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%H:%M:%S') - $1"
}

# Get the latest workflow run for the branch
get_latest_run() {
    gh run list \
        --repo "$REPO" \
        --workflow "$WORKFLOW" \
        --branch "$BRANCH" \
        --limit 1 \
        --json databaseId,status,conclusion,displayTitle,updatedAt \
        | jq -r '.[0]'
}

# Get run details
get_run_status() {
    local run_id="$1"
    gh run view "$run_id" --repo "$REPO" --json status,conclusion,displayTitle
}

# Get job details with steps
get_run_jobs() {
    local run_id="$1"
    gh run view "$run_id" --repo "$REPO" --json jobs
}

# Parse and display run status
display_run_status() {
    local run_id="$1"
    local status_data
    status_data=$(get_run_status "$run_id")
    
    local status conclusion title
    status=$(echo "$status_data" | jq -r '.status')
    conclusion=$(echo "$status_data" | jq -r '.conclusion')
    title=$(echo "$status_data" | jq -r '.displayTitle')
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Run: $title"
    echo "  ID:  $run_id"
    echo "  Status: $status"
    
    if [[ "$status" == "completed" ]]; then
        echo "  Conclusion: $conclusion"
        if [[ "$conclusion" == "success" ]]; then
            log_success "Build completed successfully!"
        else
            log_error "Build failed with conclusion: $conclusion"
        fi
    else
        echo "  Conclusion: (in progress)"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Return status for caller
    echo "$status:$conclusion"
}

# Main monitoring loop
main() {
    log_info "GitHub Actions Build Monitor"
    log_info "Repository: $REPO"
    log_info "Branch: $BRANCH"
    log_info "Workflow: $WORKFLOW"
    log_info "Check interval: ${INTERVAL}s"
    echo ""
    
    # If no RUN_ID provided, get the latest one
    if [[ -z "$RUN_ID" ]]; then
        log_info "Fetching latest workflow run..."
        local latest_run
        latest_run=$(get_latest_run)
        
        if [[ -z "$latest_run" || "$latest_run" == "null" ]]; then
            log_error "No workflow runs found for branch $BRANCH"
            exit 1
        fi
        
        RUN_ID=$(echo "$latest_run" | jq -r '.databaseId')
        local initial_status=$(echo "$latest_run" | jq -r '.status')
        
        log_info "Latest run: $RUN_ID (status: $initial_status)"
    fi
    
    # Verify the run exists
    if ! gh run view "$RUN_ID" --repo "$REPO" &>/dev/null; then
        log_error "Workflow run $RUN_ID not found"
        exit 1
    fi
    
    log_info "Starting monitoring loop. Press Ctrl+C to stop."
    echo ""
    
    local last_status=""
    local consecutive_failures=0
    local max_failures=3
    
    while true; do
        local status_data
        local current_status current_conclusion
        
        # Get current status
        status_data=$(get_run_status "$RUN_ID" 2>/dev/null) || {
            consecutive_failures=$((consecutive_failures + 1))
            if [[ $consecutive_failures -ge $max_failures ]]; then
                log_error "Failed to fetch status $max_failures times in a row. Exiting."
                exit 1
            fi
            log_warning "Failed to fetch status (attempt $consecutive_failures/$max_failures). Retrying in ${INTERVAL}s..."
            sleep "$INTERVAL"
            continue
        }
        
        consecutive_failures=0
        
        current_status=$(echo "$status_data" | jq -r '.status')
        current_conclusion=$(echo "$status_data" | jq -r '.conclusion')
        
        # Display current status
        echo ""
        log_info "Checking status..."
        
        local result
        result=$(display_run_status "$RUN_ID")
        
        # Check if status changed
        if [[ "$result" != "$last_status" ]]; then
            last_status="$result"
            
            if [[ "$current_status" == "completed" ]]; then
                echo ""
                if [[ "$current_conclusion" == "success" ]]; then
                    log_success "✅ Build completed successfully!"
                    log_info "View results at: https://github.com/$REPO/actions/runs/$RUN_ID"
                    exit 0
                else
                    log_error "❌ Build failed with conclusion: $current_conclusion"
                    log_info "View logs at: https://github.com/$REPO/actions/runs/$RUN_ID"
                    exit 1
                fi
            fi
        fi
        
        echo ""
        log_info "Next check in ${INTERVAL}s... (Ctrl+C to stop)"
        
        # Sleep with interrupt check
        sleep "$INTERVAL"
    done
}

# Check dependencies
check_deps() {
    if ! command -v gh &>/dev/null; then
        log_error "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v jq &>/dev/null; then
        log_error "jq is not installed. Please install it first."
        exit 1
    fi
}

# Run
check_deps
main
