#!/system/bin/sh
# Enhanced service script that combines features from both projects
MODDIR=${0%/*}
APEX_CERT_DIR=/apex/com.android.conscrypt/cacerts
SYS_CERT_DIR=/system/etc/security/cacerts
LOG_FILE="$MODDIR/log.txt"
TEMP_DIR="/data/local/tmp/tmp-ca-copy"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [TrustUserCerts]" "$@" >> "$LOG_FILE"
}

# Check if mount exists in a process
has_mount() {
    local pid="$1"
    grep -q " $APEX_CERT_DIR " "/proc/$pid/ns/mnt" 2>/dev/null || grep -q " $APEX_CERT_DIR " "/proc/$pid/mountinfo" 2>/dev/null
}

# Helper function to apply correct permissions
fix_permissions() {
    local target_dir="$1"
    log "Fixing permissions for $target_dir"
    chown -R root:root "$target_dir"/* 2>/dev/null
    chmod -R 644 "$target_dir"/* 2>/dev/null

    # Try multiple SELinux contexts for better compatibility across Android versions
    # Start with the most specific one and fallback to more generic ones
    if ! chcon -R u:object_r:system_security_cacerts_file:s0 "$target_dir"/* 2>/dev/null; then
        log "Using fallback SELinux context"
        if ! chcon -R u:object_r:system_file:s0 "$target_dir"/* 2>/dev/null; then
            # Final fallback for very old or unusual Android versions
            chcon -R u:object_r:system_data_file:s0 "$target_dir"/* 2>/dev/null || log "Failed to set SELinux context"
        fi
    fi
}

# Enhanced version that continuously monitors zygote processes
monitor_zygote() {
    log "Starting zygote monitor"

    (
    while true; do
        # Collect all zygote PIDs (both 32‑ and 64‑bit)
        zygote_pids=""
        for name in zygote zygote64; do
            for p in $(pidof "$name" 2>/dev/null); do
                zygote_pids="$zygote_pids $p"
            done
        done

        for zp in $zygote_pids; do
            # If our bind isn't present, re-apply it
            if ! has_mount "$zp"; then
                # Get active children - try different methods for compatibility
                children=$(echo "$zp" | xargs -n1 ps -o pid -P 2>/dev/null | grep -v PID)

                # Fallback for old Android ps (columns: USER PID PPID ...):
                if [ -z "$children" ]; then
                    # Try alternative approach for older Android versions
                    children=$(ps | awk -v PPID=$zp '$3==PPID { print $2 }')

                    # If still empty, try another ps format
                    if [ -z "$children" ]; then
                        children=$(ps -A | awk -v PPID=$zp '$2==PPID { print $1 }')
                    fi
                fi

                # After a crash, zygote is a bit unstable, so waiting to settle.
                # Only wait if we have at least some children
                if [ -n "$children" ] && [ "$(echo "$children" | wc -l)" -lt 5 ]; then
                    log "Waiting for zygote to stabilize..."
                    /system/bin/sleep 1s
                    continue
                fi

                log "Injecting into zygote ($zp)"
                /system/bin/nsenter --mount=/proc/$zp/ns/mnt -- /bin/mount --rbind "$SYS_CERT_DIR" "$APEX_CERT_DIR" 2>> "$LOG_FILE"

                # Inject mount into all child processes, if we have any
                if [ -n "$children" ]; then
                    for pid in $children; do
                        # Verify the process still exists before trying to inject
                        if [ -d "/proc/$pid" ] && ! has_mount "$pid"; then
                            log "  Injecting into child $pid"
                            /system/bin/nsenter --mount=/proc/$pid/ns/mnt -- /bin/mount --rbind "$SYS_CERT_DIR" "$APEX_CERT_DIR" 2>> "$LOG_FILE" &
                        fi
                    done
                    wait # Wait for all background processes to complete
                fi
            fi
        done
        sleep 5
    done
    ) &
}

# Setup temporary directory for cert manipulation
setup_temp_dir() {
    rm -rf "$TEMP_DIR" 2>/dev/null
    mkdir -p -m 700 "$TEMP_DIR"
    log "Created temporary directory at $TEMP_DIR"
}

# Copy certificates from source to destination
copy_certs() {
    local src="$1"
    local dest="$2"

    # Check if source directory exists and is not empty
    if [ -d "$src" ] && [ "$(ls -A "$src" 2>/dev/null)" ]; then
        cp -f "$src"/* "$dest"/ 2>/dev/null
        log "Copied certificates from $src to $dest"
    else
        log "Warning: Source directory $src does not exist or is empty"
    fi
}

# Main function
main() {
    log "======================================="
    log "TrustUserCerts Enhanced Module - Starting service.sh"
    log "Module version: $(cat "$MODDIR/module.prop" | grep version= | cut -d= -f2)"
    log "Device: $(getprop ro.product.model) ($(getprop ro.product.device))"
    log "Android version: $(getprop ro.build.version.release) (SDK $(getprop ro.build.version.sdk))"

    # Wait for boot to complete
    while [ "$(getprop sys.boot_completed)" != 1 ]; do
        /system/bin/sleep 1s
    done
    log "Boot completed"

    # Setup temp directory
    setup_temp_dir

    # Handle both certificate store types
    if [ -d "$APEX_CERT_DIR" ]; then
        log "Detected APEX Conscrypt certificate store"

        # Copy out the existing certificates from both stores
        copy_certs "$APEX_CERT_DIR" "$TEMP_DIR"
        copy_certs "$SYS_CERT_DIR" "$TEMP_DIR"

        # Create tmpfs mount on system certs folder
        if mount -t tmpfs tmpfs "$SYS_CERT_DIR"; then
            log "Successfully mounted tmpfs on $SYS_CERT_DIR"

            # Copy all certs to the tmpfs
            copy_certs "$TEMP_DIR" "$SYS_CERT_DIR"

            # Fix permissions
            fix_permissions "$SYS_CERT_DIR"

            # Start the zygote monitor to ensure APEX module has the certs
            monitor_zygote
        else
            log "Failed to mount tmpfs on $SYS_CERT_DIR"
        fi
    else
        # Handle legacy devices without APEX Conscrypt module
        log "No APEX Conscrypt module detected, using legacy mode"
        # System certs are handled in post-fs-data.sh and auto-mounted by Magisk
    fi

    # Clean up
    rm -rf "$TEMP_DIR" 2>/dev/null
    log "Finished certificate injection"
    log "======================================="
}

main
