#!/system/bin/sh

# Set directory variable
TARGET_DIR="/data/adb/tricky_store"
TARGET_FILE="$TARGET_DIR/target.txt"
TARGET_BACKUP="$TARGET_DIR/target.txt.bak"
ROM_SIGN_PATH="/system/etc/security"

# Function to check Internet connectivity
check_internet() {
    # Ping Google DNS server to check for Internet connectivity
    if ! ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        abort "! Unable to connect to Internet"  # Abort if no Internet connection
    fi
}

# Call the Internet check function
check_internet

if [ "$BOOTMODE" ] && [ "$KSU" ]; then
    echo "- Installation with KernelSU"
    # Define a function to run commands with root privileges using Magisk
    cmd() { /data/adb/ksu/bin/busybox "$@"; }
    
elif [ "$BOOTMODE" ] && [ "$APATCH" ]; then
    echo "- Installation with Apatch"
    # Define a function to run commands with root privileges using Magisk
    cmd() { /data/adb/ap/bin/busybox "$@"; }
    
elif [ "$BOOTMODE" ] && [ "$MAGISK_VER_CODE" ]; then
    echo "- Installation with Magisk $MAGISK_VER($MAGISK_VER_CODE)"
    # Define a function to run commands with root privileges using Magisk
    [ $MAGISK_VER_CODE -lt 27008 ] && cmd() { su -c "$@"; } || cmd() { /data/adb/magisk/magisk su -c "$@"; }
        
else
    # Print Abort Message
    abort "! Installation from recovery not supported"
fi


# Extract the version from the module.prop file
VERSION=$(grep 'version=' $MODPATH/module.prop | cut -d '=' -f 2)

# Display the text with the extracted version
echo -e "\nTSupport Advance ( $VERSION )"
sleep 0.8  # Delay for 0.8 seconds
echo "Open Source Project ( OSP )"
sleep 1  # Delay for 0.8 seconds
echo -e "Brought by Citra-Standalone\n"
sleep 0.5

# Indicator
echo "============================"

# ROM Sign Check
if unzip -l $ROM_SIGN_PATH/otacerts.zip | grep -q "testkey" ; then
    echo -e "ROM Sign : testkey"
elif unzip -l $ROM_SIGN_PATH/otacerts.zip | grep -q "releasekey" ; then
    echo -e "ROM Sign : releasekey"
else
    echo -e "ROM Sign : unknown"
fi

# TEE Detection
if [ -d "$TARGET_DIR" ] && grep -q "teeBroken=true" "$TARGET_DIR/tee_status"; then
    echo -e "TEE Status : broken"
elif [ -d "$TARGET_DIR" ] && grep -q "teeBroken=false" "$TARGET_DIR/tee_status"; then
    echo -e "TEE Status : normal"
else
    echo -e "TEE Status : unknown"
fi

# XiaomiEU Disable Inject Module
if pm list packages | grep eu.xiaomi.module.inject >> /dev/null; then
    echo "XEU ROM : true"
    su -c pm disable eu.xiaomi.module.inject >> /dev/null
else
    echo "XEU ROM : false"
fi

# Close Indicator
echo "============================"

# Checking Tricky Store directory
if [ -d "$TARGET_DIR" ]; then
    # Checking target.txt
    if [ -f "$TARGET_FILE" ]; then
        # Check target.txt backup
        if [ -f "$TARGET_BACKUP" ]; then
            # Remove target.txt
            su -c rm -rf "$TARGET_FILE"
        else
            # Backup target.txt
            su -c mv "$TARGET_FILE" "$TARGET_BACKUP" && ui_print "> Backup done🥰"
        fi
    fi
    
    # Getting all installed package name
    packages=$(su -c pm list packages | awk -F: '{print $2}')
    
    # CITarget Indicator
    echo -e "\n=== CITarget ==="
    [ -f /sdcard/exclude.txt ] && echo "> exclude.txt found"
    
    # Looping
    for package in $packages; do
        # Check if exclude
        # Check exclude.txt if has '!'
        if [ -f /sdcard/exclude.txt ] && cat /sdcard/exclude.txt | grep $package! >> /dev/null ; then
            echo "> $package will be added without [!]"
            # Add package to target.txt without '!'
            echo "$package" >> "$TARGET_FILE"
            continue
        elif [ -f /sdcard/exclude.txt ] && cat /sdcard/exclude.txt | grep $package >> /dev/null ; then
            # Print excluded package name
            echo "> $package excluded"
            sleep 0.5
            continue
        else
            # Add package to target.txt
            echo "$package!" >> "$TARGET_FILE"
        fi
    done
    echo "> Done adding package to target.txt"
    echo "=== ENDED ==="
else
    # Message from Citra
    echo "=== ERROR ==="
    sleep 1
    echo "> Hello there👋🏻"
    sleep 0.5
    echo "> You got message from Citra 💌."
    sleep 1
    echo "> Is tricky store installed 🤔?"
    sleep 1
    echo "> Please reinstall tricky store😑."
    sleep 3.5 && exit
fi

set +o standalone
unset ASH_STANDALONE

# Check if the fp.sh file exists and execute it with root privileges
[ -f $MODPATH/fp.sh ] && cmd sh $MODPATH/fp.sh || echo -e "! Skip Fingerprint Generator"

# Check if the key.sh file exists and execute it with root privileges
[ -f $MODPATH/key.sh ] && cmd sh $MODPATH/key.sh || echo -e "! Skip Key Generator"

# Remove the key file if it exists
[ -f $MODPATH/key ] && rm -rf "$MODPATH/key"

# Remove PIXEL_BETA_HTML file if it exists
[ -f $DIR/PIXEL_BETA_HTML ] && su -c "rm -rf $MODPATH/BETA"

# Remove PIXEL_GET_HTML file if it exists
[ -f $DIR/PIXEL_GET_HTML ] && su -c "rm -rf $MODPATH/GET_PIXEL"

# Remove PIXEL_GSI_HTML file if it exists
[ -f $DIR/PIXEL_GSI_HTML ] && su -c "rm -rf $MODPATH/PIXEL"