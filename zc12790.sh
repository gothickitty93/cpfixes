#!/bin/bash
#Apache crashing with Mutex errors for the Prefork MPM
set -euo pipefail

TEMPLATE_DIR="/var/cpanel/templates/apache2_4"
DEFAULT_TEMPLATE="$TEMPLATE_DIR/ea4_main.default"
LOCAL_TEMPLATE="$TEMPLATE_DIR/ea4_main.local"
BACKUP_TEMPLATE="$TEMPLATE_DIR/ea4_main.local.bak"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Check existence of default template
if [[ ! -f "$DEFAULT_TEMPLATE" ]]; then
    log "ERROR: Default template not found at $DEFAULT_TEMPLATE"
    exit 1
fi

# Copy default to local if it doesn't exist
if [[ ! -f "$LOCAL_TEMPLATE" ]]; then
    log "Creating local template from default..."
    cp -avp "$DEFAULT_TEMPLATE" "$LOCAL_TEMPLATE"
else
    log "Local template already exists. Skipping copy."
fi

# Backup the current local template before editing
if [[ ! -f "$BACKUP_TEMPLATE" ]]; then
    log "Backing up existing local template..."
    cp -avp "$LOCAL_TEMPLATE" "$BACKUP_TEMPLATE"
else
    log "Backup already exists. Skipping backup."
fi

# Replace Mutex definition
if grep -q 'Mutex pthread default' "$LOCAL_TEMPLATE"; then
    log "Modifying Mutex settings in local template..."
    sed -i 's|Mutex pthread default|Mutex file:[% paths.dir_run %] rewrite-map\
Mutex file:[% paths.dir_run %] ssl-cache|' "$LOCAL_TEMPLATE"
else
    log "No 'Mutex pthread default' found — assuming already modified. Skipping edit."
fi

# Rebuild and restart Apache
log "Rebuilding Apache configuration..."
/usr/local/cpanel/scripts/rebuildhttpdconf

log "Restarting Apache service..."
/usr/local/cpanel/scripts/restartsrv_httpd --hard

log "Workaround applied successfully."
