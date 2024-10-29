#!/system/bin/sh

# Set directory variable
TARGET_DIR="/data/adb/tricky_store"
TARGET_FILE="$TARGET_DIR/target.txt"
TARGET_BACKUP="$TARGET_DIR/target.txt.bak"

#Sleep and wait for 30 second before execution
sleep 30

# Loopers Services
while true; do
    # Checking if no stop-tspa-auto-target file & Tricky Store directory
    if [ ! -f /sdcard/stop-tspa-auto-target ] && [ -d "$TARGET_DIR" ]; then
        # Checking target.txt
        if [ -f "$TARGET_FILE" ]; then
            # Check target.txt backup
            if [ ! -f "$TARGET_BACKUP" ]; then
                # Backup target.txt
                su -c mv "$TARGET_FILE" "$TARGET_BACKUP"
            fi
        fi
        
        # Getting all installed package names
        packages=$(su -c pm list packages | awk -F: '{print $2}')
        
        # Looping through packages
        for package in $packages; do
            # Check if exclude.txt exists and package is listed
            if [ -f /sdcard/exclude.txt ] && grep -q "$package!" /sdcard/exclude.txt; then
                # Add package to AutoLog without '!'
                echo "$package" >> "$TARGET_DIR/autolog"
            elif [ -f /sdcard/exclude.txt ] && grep -q "$package" /sdcard/exclude.txt; then
                # Exclude the package (continue)
                continue
            else
                # Add package to AutoLog with '!'
                echo "$package!" >> "$TARGET_DIR/autolog"
            fi
        done
        # Pull AutoLog to target.txt
        [ -f $TARGET_DIR/autolog ] && su -c cat "$TARGET_DIR/autolog" > "$TARGET_FILE" && rm -rf $TARGET_DIR/autolog
        # Sleep for 1 minutes before next iteration
        sleep 60
    # If auto disable file there
    elif [ -f /sdcard/stop-tspa-auto-target ]; then
        # Break the loop
        break
    fi
done