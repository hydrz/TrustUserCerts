#!/system/bin/sh
# Enhanced post-fs-data script that handles certificate collection
MODDIR=${0%/*}
SYS_CERT_DIR=/system/etc/security/cacerts
LOG_FILE="$MODDIR/log.txt"

# Ensure log file exists and is empty for new boot cycle
echo "" > "$LOG_FILE"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [TrustUserCerts]" "$@" >> "$LOG_FILE"
}

# Collect user certificates from all user profiles
collect_user_certs() {
    log "Starting user certificate collection"

    # Create target directory if it doesn't exist
    mkdir -p "$MODDIR$SYS_CERT_DIR"

    # Clean directory first to ensure removed certs don't persist
    rm -rf "$MODDIR$SYS_CERT_DIR"/*
    log "Cleaned existing certificate directory"

    # Add system certs first
    if [ -d "$SYS_CERT_DIR" ]; then
        cp -f "$SYS_CERT_DIR"/* "$MODDIR$SYS_CERT_DIR"/ 2>/dev/null
        log "Copied system certificates"
    fi

    # Track total number of certificates
    local cert_count=0

    # Add user-defined certs, looping over all available users
    for dir in /data/misc/user/*/; do
        user_id=$(basename "$dir")
        if [ -d "${dir}cacerts-added" ]; then
            log "Processing certificates for user $user_id"
            for cert in "${dir}cacerts-added"/*; do
                if [ -f "$cert" ]; then
                    cp -f "$cert" "$MODDIR$SYS_CERT_DIR"/ 2>/dev/null
                    cert_name=$(basename "$cert")
                    log "Added user cert: $cert_name (user $user_id)"
                    cert_count=$((cert_count + 1))
                fi
            done
        fi
    done

    # Fix permissions to ensure system can read certificates
    chown -R root:root "$MODDIR$SYS_CERT_DIR"/* 2>/dev/null
    chmod -R 644 "$MODDIR$SYS_CERT_DIR"/* 2>/dev/null

    log "Collected $cert_count user certificates"

    # Verify certificates were copied
    local total=$(ls -1 "$MODDIR$SYS_CERT_DIR"/* 2>/dev/null | wc -l)
    log "Total certificates prepared: $total"
}

# Check for APEX Conscrypt directory
check_conscrypt() {
    if [ -d "/apex/com.android.conscrypt/cacerts/" ]; then
        log "APEX Conscrypt certificate store detected"
        # Certificates will be handled in service.sh for APEX
        touch "$MODDIR/.uses_conscrypt"
    else
        log "Legacy certificate store mode"
        rm -f "$MODDIR/.uses_conscrypt" 2>/dev/null
    fi
}

# Detect SELinux status
check_selinux() {
    if [ -e "/sys/fs/selinux/enforce" ]; then
        local status=$(cat /sys/fs/selinux/enforce)
        if [ "$status" = "1" ]; then
            log "SELinux is Enforcing"
        else
            log "SELinux is Permissive/Disabled ($status)"
        fi
    else
        log "SELinux not detected"
    fi
}

# Main function
main() {
    log "======================================="
    log "TrustUserCerts Enhanced Module - Starting post-fs-data.sh"
    log "Module version: $(cat "$MODDIR/module.prop" | grep version= | cut -d= -f2)"

    # Determine device and Android information
    log "Device: $(getprop ro.product.model) ($(getprop ro.product.device))"
    log "Android version: $(getprop ro.build.version.release) (SDK $(getprop ro.build.version.sdk))"

    # Check SELinux status
    check_selinux

    # Check for Conscrypt
    check_conscrypt

    # Collect all certificates
    collect_user_certs

    log "Certificate preparation completed"
    log "======================================="
}

# Execute main function
main
